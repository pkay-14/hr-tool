window.sortingSandbox = {
  _sortingOrder: -1,
  sortingOrder: undefined,
  _sortBy: 'status',

  sort: function(rout, payload, sortBy, sortingIcon) {
    sortBy = sortBy || 'status';
    sortingIcon = sortingIcon || '[data-sorting-icon]';

    if (this._sortBy !== sortBy) {
      this.resetSortinOrder();
      this._sortBy = sortBy;
    }
    this._sortingOrder *= -1;
    this._setSortingOrder(this._sortingOrder);
    this._sendSortingReq(rout, payload, sortingIcon);
  },

  toggleSortingIcon: function(sortingIcon) {
    if (this._sortingOrder === 1) {
      $(sortingIcon).removeClass('fa-sort align-start fa-sort-down align-center').addClass('fa-sort-up align-end');
    } else {
      $(sortingIcon).removeClass('fa-sort align-end fa-sort-up align-center').addClass('fa-sort-down align-start');
    }
  },

  resetSortinOrder: function() {
    this._sortingOrder = -1;
    this.sortingOrder = undefined;
  },

  getSortingOrder: function() {
    return this.sortingOrder;
  },

  getSortByField: function() {
    return this._sortBy;
  },

  _setSortingOrder: function(order) {
    this.sortingOrder = order;
  },

  _sendSortingReq: function(rout, payload, sortingIcon) {
    var self = this;
    var sortingOrder = this._sortingOrder === 1 ? 'asc' : 'desc';

    if (rout.indexOf('projects') !== -1) {
      payload.status_order = sortingOrder;
    } else {
      payload.order = sortingOrder;
    }

    $.ajax({
      url: rout,
      type: 'GET',
      data: payload,
      success: function(data) {
        self.toggleSortingIcon(sortingIcon);
        $('[data-sorting-icon]').attr('data-projects-sorting', sortingOrder);
      }
    });
  }
};
