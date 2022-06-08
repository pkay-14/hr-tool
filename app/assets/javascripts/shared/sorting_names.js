const sortingSandboxName = {
  _sortingOrder: -1,
  sortingOrder: undefined,
  _sortBy: 'status',

  sort: function(rout, payload, sortBy) {
    sortBy = sortBy || 'status';

    if (this._sortBy !== sortBy) {
      this.resetSortinOrder();
      this._sortBy = sortBy;
    }
    this._sortingOrder *= -1;
    this._setSortingOrder(this._sortingOrder);
    this._sendSortingReq(rout, payload);
  },

  resetSortinOrder: function() {
    this._sortingOrder = -1;
    this.sortingOrder = undefined;
  },

  _setSortingOrder: function(order) {
    this.sortingOrder = order;
  },

  _sendSortingReq: function(rout, payload) {
    const sortingOrder = this._sortingOrder === 1 ? 'ascending' : 'descending';

    if (rout.indexOf('projects') !== -1) {
      payload.status_order = sortingOrder;
    } else {
      payload.sort_name = sortingOrder;
    }

    $.ajax({
      url: rout,
      type: 'GET',
      data: payload
    });
  }
};
