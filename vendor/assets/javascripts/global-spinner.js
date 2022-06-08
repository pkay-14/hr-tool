(function () {
  const spinnerCreatedTimestampDataAttributeName = 'spinnerCreatedTimestamp'; // data attribute for spinner DOM element. Contains spinner created timestamp
  const spinnerDomContainerForElementClassName = 'global-spinner-overlay--element-partial'; // CSS style for spinner container for insert into element
  const spinnerDomContainerForFullScreenClassName = 'global-spinner-overlay--element';   // CSS style for spinner fullscreen container (overlay)

  const spinnerDefaultParams = {
    spinnerDomId: 'global-spinner--id',  //spinner id in DOM: <div id=`${spinnerDomId}`></>
    spinnerDomContainerSelector: 'body',  //spinner container selector (where spinner will add) document.querySelector(`${spinnerDomContainerSelector}`)
    spinnerDomClassName: 'global-spinner--element',  // class name for spinner container (css style)
    spinnerDomContainerClassName: spinnerDomContainerForFullScreenClassName,  // class name for spinner container (css style)
    hideSpinnerBackgroundOverlay: false,  //  make spinner container background style transparent
    minimalWorkTimeInMilliseconds: 1420,  //  minimum spinner work time before close in milliseconds
  }

  function getSpinnerDomContainer(spinnerDomContainerSelector) {
    return document.querySelector(spinnerDomContainerSelector);
  }

  function getSpinnerDomElement(spinnerDomId) {
    return document.querySelector(`#${spinnerDomId}`);
  }

  function createSpinnerDomElement(params) {
    const spinnerDomElement = document.createElement('div');
    const spinnerDomBackgroundElement = document.createElement('div');

    spinnerDomElement.className = params.spinnerDomClassName;
    spinnerDomBackgroundElement.dataset[spinnerCreatedTimestampDataAttributeName] = (Date.now()).toString();
    spinnerDomBackgroundElement.id = params.spinnerDomId;
    spinnerDomBackgroundElement.className = params.spinnerDomContainerClassName;

    if (params.hideSpinnerBackgroundOverlay) {
      spinnerDomBackgroundElement.style.background = 'transparent';
    }

    spinnerDomBackgroundElement.appendChild(spinnerDomElement);

    return spinnerDomBackgroundElement;
  }

  function addSpinnerToDom(params) {
    const spinnerDomElement = getSpinnerDomElement(params.spinnerDomId);

    if (!spinnerDomElement) {
      getSpinnerDomContainer(params.spinnerDomContainerSelector)
        .appendChild(createSpinnerDomElement(params));
    }
  }

  function removeSpinnerFromDom(params) {
    const spinnerDomElement = getSpinnerDomElement(params.spinnerDomId);

    if (!spinnerDomElement) {
      return;
    }

    const spinnerDomContainer = spinnerDomElement.parentElement;

    if (spinnerDomElement && spinnerDomContainer) {
      spinnerDomContainer.removeChild(spinnerDomElement);

      if (params.callbackToRunAfterRemoveSpinner) {
        params.callbackToRunAfterRemoveSpinner();
      }
    }
  }

  function removeSpinnerFromDomByTimeout(spinnerParams) {
    const spinnerDomElement = getSpinnerDomElement(spinnerParams.spinnerDomId);
    if (!spinnerDomElement) {
      return;
    }

    const spinnerCreatedTime = Number(spinnerDomElement.dataset[spinnerCreatedTimestampDataAttributeName]);
    const closeTimeout = spinnerCreatedTime + spinnerParams.minimalWorkTimeInMilliseconds - Date.now();

    if (spinnerParams.minimalWorkTimeInMilliseconds <= 0 || closeTimeout <= 0) {
      removeSpinnerFromDom(spinnerParams);
    } else {
      setTimeout(() => removeSpinnerFromDom(spinnerParams), closeTimeout);
    }
  }

  function setSpinner(spinnerParams) {
    addSpinnerToDom({...spinnerDefaultParams, ...spinnerParams});
  }

  function getSpinnerDefaultParamsForInsertToElement(spinnerDomContainerSelector, spinnerDomId = spinnerDefaultParams.spinnerDomId) {
    const params = {...spinnerDefaultParams}
    params.spinnerDomContainerSelector = spinnerDomContainerSelector;
    params.spinnerDomId = spinnerDomId;
    params.spinnerDomContainerClassName = spinnerDomContainerForElementClassName;
    params.hideSpinnerBackgroundOverlay = true;

    return params;
  }

  const spinner = {};

  /**
   * Return spinnerDefaultParams object. Contains all params for setSpinner function
   */
  spinner.getSpinnerDefaultParams = () => {
    return spinnerDefaultParams;
  }

  /**
   * Get default params for create spinner for element
   */
  spinner.getSpinnerDefaultParamsForInsertToElement = getSpinnerDefaultParamsForInsertToElement;

  /**
   * Insert spinner into <body> tag
   * @param hideSpinnerBackgroundOverlay if true -- make transparent spinner background container
   */
  spinner.add = (hideSpinnerBackgroundOverlay = false) => {
    const params = {...spinnerDefaultParams};

    params.hideSpinnerBackgroundOverlay = hideSpinnerBackgroundOverlay;
    params.spinnerDomContainerSelector = 'body';

    setSpinner(params);

    return params;
  }

  /**
   * Remove spinner from element after timeout
   * @param spinnerDomId spinner id in DOM (<div id='spinnerDomId'> spinner </div>)
   * @param callbackToRunAfterRemoveSpinner function to run after spinner removed
   */
  spinner.remove = (callbackToRunAfterRemoveSpinner = null, spinnerDomId = spinnerDefaultParams.spinnerDomId) => {
    const params = {...spinnerDefaultParams}

    params.spinnerDomId = spinnerDomId;
    params.callbackToRunAfterRemoveSpinner = callbackToRunAfterRemoveSpinner;

    removeSpinnerFromDomByTimeout(params);
  }

  /**
   * Remove spinner from element immediately
   * @param spinnerDomId spinner id in DOM (<div id='spinnerDomId'> spinner </div>)
   */
  spinner.removeImmediately = (spinnerDomId = spinnerDefaultParams.spinnerDomId) => {
    const params = {...spinnerDefaultParams}

    params.spinnerDomId = spinnerDomId;

    removeSpinnerFromDom(params);
  }

  /**
   * Insert spinner into exist element
   * Spinner has an absolute position, so, element must have a position style (absolute, relative, sticky)
   * @param spinnerDomContainerSelector: element where need to set spinner div for document.querySelector(spinnerDomContainerSelector) function
   * @param spinnerDomId: spinner id in DOM (<div id='spinnerDomId'> spinner </div>)
   * @param hideSpinnerBackgroundOverlay Make spinner container transparent
   */
  spinner.addToElement = (spinnerDomContainerSelector, spinnerDomId = spinnerDefaultParams.spinnerDomId, hideSpinnerBackgroundOverlay = true) => {
    const params = getSpinnerDefaultParamsForInsertToElement(spinnerDomContainerSelector, spinnerDomId);
    params.hideSpinnerBackgroundOverlay = hideSpinnerBackgroundOverlay;

    setSpinner(params);
  }

  /**
   * Add or remove spinner in some element
   * @param spinnerParams: object as "spinnerDefaultParams"
   */
  spinner.setSpinner = setSpinner;

  window.spinner = spinner;
}());
