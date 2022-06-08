/**
   * Implements switching logic for the tab: you click on tabTitle - appears related tabBody
   * @param option.active - the number of initially active tab (starting from 0)
   * @param option.selector - css selector of main tabs container, by default '#tabs'
   * @param option.tabTitleClass - css class name of tab title, by default 'mm-switcher__item'
   * @param options.activeTabTitleClass - css class name of active tab title, by default `${tabTitleClass}--active`
   * @param option.tabBodyClass - css class name of tab body, by default 'mm-switcher__body'
   * @param options.activeTabBodyClass - css class name of active tab body, by default `${tabBodyClass}--active`
   * @param option.tabNamesArr - support of saving open tab in query params in url.
   * If this parameter is not passed to options, saving of open tab in url will not exist.
   * Example of usage:
   * option.tabNamesArr = ['selfFeedback', 'feedbackRequest', 'feedbackResult']
   *         tabs number:  0                1                  2
   * Page is loading with query params '?tab=feedbackRequest' opens tab nubmer 1.
   * Switching to tab number 2 will change query params to ?tab=feedbackResult
   */
 class Tabs {
  constructor(options) {
    const tabTitleClass = options.tabTitleClass || 'mm-switcher__item';
    const tabBodyClass = options.tabBodyClass || 'mm-switcher__body';

    const tabsElem = document.querySelector(options.selector);

    if (!tabsElem) {
      this.onError();
      return;
    }

    this.activeTabTitleClass = options.activeTabTitleClass || `${tabTitleClass}--active`;
    this.activeTabBodyClass = options.activeTabBodyClass || `${tabBodyClass}--active`;

    this._tabNamesArr = options.tabNamesArr || null;
    this.active = this.getActiveTabFromSearchParams() || options.active || 0;


    this.tabs = Array.from(tabsElem.getElementsByClassName(tabTitleClass));
    this.tabBodies = document.getElementsByClassName(tabBodyClass);

    if (!this.tabs.length ||
      !this.tabBodies.length ||
      this.tabs.length !== this.tabBodies.length) {
      this.onError();
      // eslint-disable-next-line no-console
      console.dir(tabsElem);
      return;
    }

    this.tabs.forEach((tab) => tab.addEventListener('click', () => this.activateTab(tab)));
    this.activateTab(this.tabs[this.active]);

    window.addEventListener('popstate', this.onPopState.bind(this))
  }

  activateTab(tab) {
    const index = this.tabs.indexOf(tab);

    this.tabs[this.active].classList.remove(this.activeTabTitleClass);
    this.tabBodies[this.active].classList.remove(this.activeTabBodyClass);

    tab.classList.add(this.activeTabTitleClass);
    this.tabBodies[index].classList.add(this.activeTabBodyClass);

    this.active = index;

    if (this._tabNamesArr && this.active !== this.getActiveTabFromSearchParams()) {
      this.setActiveTabToSearchParams(this.active);
    }
  }

  onError() {
    console.warn('There is some problem with the Tabs component');
  }

  getActiveTabFromSearchParams() {
    if (!this._tabNamesArr) {
      return null;
    }
    const searchParams = new URLSearchParams(window.location.search);
    const tabName = searchParams.get('tab');
    const tabIndex = this._tabNamesArr.indexOf(tabName);

    return  tabIndex === -1 ? null : tabIndex;
  }

  setActiveTabToSearchParams(tabNumber) {
    const searchParams = new URLSearchParams(window.location.search);

    searchParams.set('tab', this._tabNamesArr[tabNumber]);
    const newRelativePathQuery = `${window.location.pathname}?${searchParams.toString()}`;

    history.pushState(null, '', newRelativePathQuery);
  }

  onPopState() {
    const newActiveTabNumber = this.getActiveTabFromSearchParams();

    if (newActiveTabNumber !== null && newActiveTabNumber !== this.active) {
      this.activateTab(this.tabs[newActiveTabNumber]);
    }
  }
}
