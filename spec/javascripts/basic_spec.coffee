# http://jasmine.github.io/edge/introduction.html
# https://github.com/searls/jasmine-rails
# https://github.com/velesin/jasmine-jquery
# https://github.com/travisjeffery/jasmine-jquery-rails
# http://coffeescript.org/
# https://angular.github.io/protractor/#/tutorial
# https://github.com/tyronewilson/protractor-rails

describe 'Foo', ->

  beforeEach ->
    browser.get('/')

  it 'does something', ->
    expect(browser.getTitle()).toBe "TheBlockBot"
