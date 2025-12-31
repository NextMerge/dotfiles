// biome-ignore lint/complexity/useArrowFunction: nah
(function () {
  let timer = null;

  // Tab URL changes -> capture the tab after a delay and update Vivaldi's thumbnail
  chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
    if (changeInfo.url && timer === null && tab.active) {
      timer = setTimeout(
        async () => {
          try {
            const tabCapture = await chrome.tabs.captureVisibleTab(
              tab.windowId,
            );

            const vivExtData = JSON.parse(tab.vivExtData);
            vivExtData.thumbnail = tabCapture;

            await chrome.tabs.update(tabId, {
              vivExtData: JSON.stringify(vivExtData),
            });
          } catch (error) {
            console.error(error);
          } finally {
            timer = null;
          }
        },
        Math.max(
          1000 / chrome.tabs.MAX_CAPTURE_VISIBLE_TAB_CALLS_PER_SECOND,
          2000,
        ),
      );
    }
  });

  // Switch tabs -> clear the timer
  chrome.tabs.onActivated.addListener(() => {
    if (timer !== null) {
      clearTimeout(timer);
      timer = null;
    }
  });

  // Tab closed -> clear the timer
  chrome.tabs.onRemoved.addListener(() => {
    if (timer !== null) {
      clearTimeout(timer);
      timer = null;
    }
  });
})();
