
var LineChartView = BaseChartView.extend({
  initialize : function() {
    this.initialize_defaults();
  },

  render : function() {
    this.clear_container();
    InitializeLine(this.model.get("container"), 
      this.model.results(), 
      this.model.get('unit'), 
      this.model.colors(), 
      this.model.labels());
  }
});