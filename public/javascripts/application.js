OpenIDFoo = Class.create({

  defaultProviders: {
    myopenid: {name: 'myOpenID', url: 'http://{id}.myopenid.com/'},
    yahoo: {name: 'Yahoo!', url: 'http://yahoo.com/{id}'}
  },

  initialize: function(el){
    this.input = $(el);
    this.insert();
  },

  insert: function(){
    this.list = this.generateList();
    this.button = this.generateButton();
    this.input.insert({after:this.button});
    this.button.insert({after:this.list});
  },
  
  generateList: function(providers){
    providers = providers || this.defaultProviders;
    var list = new Element('ul', {'class':'openid-providers'});
    Object.keys(providers).each(function(label){
      var li = new Element('li', {'class':'openid-provider '+label});
      li.update(new Element('a', {href:'#'}).update(providers[label].name));
      list.insert({bottom:li});
    });

    var that = this;
    list.observe('click', function(e){
      e.stop();
      list.select('li').invoke('removeClassName', 'selected');
      var el = e.findElement('li');
      el && Object.keys(providers).each(function(label){
        if (el.hasClassName(label)) {
          el.addClassName('selected');
          that.input.value = providers[label].url;
          that.deactivateList();
          that.focus();
          return;
        }
      });
    });
    return list;
  },

  generateButton: function(label, options){
    label = label || '▾';
    button = new Element('button', Object.extend({'class':'openid-selector'}, options || {}));
    button.update(label);
    button.observe('click', function(e){
      e.stop();
      this.toggleList();
    }.bindAsEventListener(this));
    return button;
  },

  activateList: function(){ this.list.addClassName('active'); },
  deactivateList: function(){ this.list.removeClassName('active'); },
  listActive: function(){ return this.list.hasClassName('active'); },
  toggleList: function(){ this.list[this.listActive() ? 'removeClassName' : 'addClassName']('active'); },

  focus: function(){ this.input.focus(); }

});

/*
document.observe('dom:loaded', function(){
  new OpenIDFoo('openid_identifier');
});
*/
