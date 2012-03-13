/* DO NOT MODIFY. This file was compiled Wed, 07 Mar 2012 08:35:16 GMT from
 * /Users/paozac/Sites/etmodel/app/coffeescripts/lib/models/scatter_chart_serie.coffee
 */

(function() {
  var __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  this.ScatterChartSerie = (function(_super) {

    __extends(ScatterChartSerie, _super);

    function ScatterChartSerie() {
      ScatterChartSerie.__super__.constructor.apply(this, arguments);
    }

    ScatterChartSerie.prototype.initialize = function() {
      var key, query_x, query_y;
      key = this.get('gquery_key');
      query_x = "" + key + "_costs";
      query_y = "" + key + "_emissions";
      return this.set({
        gquery_x: new Gquery({
          key: query_x
        }),
        gquery_y: new Gquery({
          key: query_y
        })
      });
    };

    ScatterChartSerie.prototype.result = function() {
      return [this.get('gquery_x').get('future_value'), this.get('gquery_y').get('future_value')];
    };

    return ScatterChartSerie;

  })(Backbone.Model);

  this.ScatterChartSeries = (function(_super) {

    __extends(ScatterChartSeries, _super);

    function ScatterChartSeries() {
      ScatterChartSeries.__super__.constructor.apply(this, arguments);
    }

    ScatterChartSeries.prototype.model = ScatterChartSerie;

    return ScatterChartSeries;

  })(Backbone.Collection);

}).call(this);