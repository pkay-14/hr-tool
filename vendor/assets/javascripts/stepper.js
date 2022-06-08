/**
 * @description
 * Vanilla Javascript Stepper
 *
 * @class
 * @param {string} options.elem - HTML id of the tabs container
 * @param {number} [options.opened = 0] - Render the tabs with this item open
 * @param {number} [options.titleClass = 'stepper__title'] - Class of the tab title
 * @param {number} [options.openedClass = 'stepper__title--opened'] - Class of the opened tab
 * @param {number} [options.passedClass = 'stepper__title--passed'] - Class of the passed tab
 * @param {number} [options.toFillClass = 'stepper__title--to-fill'] - Class of the tab to fill (accessible one)
 * @param {number} [options.contentClass = 'stepper__content'] - Class of the tabs content
 * @param {number} [options.openTabCallback = empty function] - Callback, which will be called on every tabs opening
 */
var Stepper = function (options) {
  var elem = document.getElementById(options.elem),
    tabsState = {
      opened: options.opened || 0,
      active: options.active || options.opened || 0
    },
    titleClass = options.titleClass || "stepper__title",
    openedClass = options.openedClass || "stepper__title--opened",
    passedClass = options.passedClass || "stepper__title--passed",
    toFillClass = options.toFillClass || "stepper__title--to-fill",
    contentClass = options.contentClass || "stepper__content",
    tabsNum = elem.querySelectorAll("." + titleClass).length;

  openTabCallback = options.openTabCallback || function () {};
  render();

  /**
   * Initial rendering of the tabs.
   */
  function render(n) {
    elem.addEventListener("click", onClick);

    var init = n == undefined ? checkTab(tabsState.opened) : checkTab(n);

    for (var i = 0; i < tabsNum; i++) {
      var currentEl = elem.querySelectorAll("." + titleClass)[i];
      currentEl.setAttribute("data-index", i);
      if (i === init) {
        openTab(i);
        currentEl.classList.add(toFillClass);
      }
    }
  }

  /**
   * Handle clicks on the tabs.
   *
   * @param {object} e - Element the click occured on.
   */
  function onClick(e) {
    var tabTitleElem = e.target.closest("." + titleClass);
    if (!tabTitleElem) {
      return;
    }
    var isActive = tabTitleElem.dataset.index == tabsState.active;
    var isPassed = +tabTitleElem.dataset.index < tabsState.active;

    if (!(isPassed || isActive)) {
      return;
    }

    e.preventDefault();
    openTab(+tabTitleElem.dataset.index);
  }

  /**
   * Hide all tabs and re-set tab titles.
   */
  function reset() {
    [].forEach.call(elem.querySelectorAll("." + contentClass), function (item) {
      item.style.display = "none";
    });

    [].forEach.call(elem.querySelectorAll("." + titleClass), function (item) {
      item.className = removeClass(item.className, openedClass);
    });
  }

  /**
   * Utility function to remove the open class from tab titles.
   *
   * @param {string} str - Current class.
   * @param {string} cls - The class to remove.
   */
  function removeClass(str, cls) {
    var reg = new RegExp("( )" + cls + "()", "g");
    return str.replace(reg, "");
  }

  /**
   * Utility function to remove the open class from tab titles.
   *
   * @param n - Tab to open.
   */
  function checkTab(n) {
    return n < 0 || isNaN(n) || n >= tabsNum ? 0 : n;
  }

  /**
   * Opens a tab by index.
   *
   * @param {number} n - Index of tab to open. Starts at 0.
   *
   * @public
   */
  function openTab(n) {
    reset();

    var i = checkTab(n);

    elem.querySelectorAll("." + titleClass)[i].className += " " + openedClass;
    elem.querySelectorAll("." + contentClass)[i].style.display = "";

    tabsState.opened = i;

    openTabCallback(i);
  }

  /**
   * Go to the next tab and mark leaved tab as passed.
   */
  function next() {
    var lastOpenedTab = +tabsState.opened;
    var nextTab = lastOpenedTab + 1;
    var lastOpenedTabEl = elem.querySelectorAll("." + titleClass)[
      lastOpenedTab
    ];
    openTab(nextTab);
    lastOpenedTabEl.classList.add(passedClass);
    if (tabsState.active < nextTab) {
      tabsState.active = nextTab;
      elem
        .querySelectorAll("." + titleClass)
        [nextTab].classList.add(toFillClass);
      lastOpenedTabEl.classList.remove(toFillClass);
    }
  }

  /**
   * Go one tab back.
   */
  function stepBack() {
    var nextTab = +tabsState.opened - 1;
    openTab(nextTab);
  }

  /**
   * Updates the tabs.
   *
   * @param {number} n - Index of tab to open. Starts at 0.
   *
   * @public
   */
  function update(n) {
    destroy();
    reset();
    render(n);
  }

  /**
   * Removes the listeners from the tabs.
   *
   * @public
   */
  function destroy() {
    elem.removeEventListener("click", onClick);
  }

  return {
    tabsState: tabsState,
    open: openTab,
    next: next,
    stepBack: stepBack,
    update: update,
    destroy: destroy
  };
};
