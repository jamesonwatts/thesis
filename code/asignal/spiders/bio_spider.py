from scrapy.spider import BaseSpider
from scrapy.selector import HtmlXPathSelector
from scrapy.http import Request
from scrapy.http import FormRequest
from asignal.items import BioItem

class BioSpider(BaseSpider):
    name = "bio"
    allowed_domains = ["bioworld.com"]
    start_urls = ['http://www.bioworld.com/node?destination=node']
    primary_urls = ['http://www.bioworld.com/bioworld/today/archive/list/201201',
                    'http://www.bioworld.com/bioworld/today/archive/list/201202',
                    'http://www.bioworld.com/bioworld/today/archive/list/201203',
                    'http://www.bioworld.com/bioworld/today/archive/list/201204',
                    'http://www.bioworld.com/bioworld/today/archive/list/201205',
                    'http://www.bioworld.com/bioworld/today/archive/list/201206',
                    'http://www.bioworld.com/bioworld/today/archive/list/201207',
                    'http://www.bioworld.com/bioworld/today/archive/list/201208',
                    'http://www.bioworld.com/bioworld/today/archive/list/201209',
                    'http://www.bioworld.com/bioworld/today/archive/list/201210',
                    'http://www.bioworld.com/bioworld/today/archive/list/201211',
                    'http://www.bioworld.com/bioworld/today/archive/list/201212']
    test_url = "http://www.bioworld.com/content/financings-roundup-396"
        
    def parse(self, response):
        return [FormRequest.from_response(response,formdata={'name': 'jamesonw', 'pass': 'alwaysHumbl3/'}, callback=self.after_login)]
    
    def after_login(self, response):
        if "My Account" in response.body:
            #return Request(self.test_url, callback=self.test)
            for url in self.primary_urls:
                yield Request(url, callback=self.parse1)
        else:
            print "BUMMER!"
    
    def test(self, response):
        hxs = HtmlXPathSelector(response)
        div = hxs.select('//div[@id="content-area"]')
        for p in div.select('.//p'):
            print p.extract()
        return Request("http://www.bioworld.com/logout", callback=self.done)    
            
    def done(self, response):
        self.log("ALL DONE")

    def parse1(self, response):
        hxs = HtmlXPathSelector(response)
        links = hxs.select('//a[contains(@href, "archive/view/")]')
        for index, link in enumerate(links):
            url = link.select('@href').extract()[0]
            if url.find("www.bioworld.com") == -1:
                url = "http://www.bioworld.com"+url
            yield Request(url, callback=self.parse2)                        
    
    def parse2(self, response):
        hxs = HtmlXPathSelector(response)
        ilist = hxs.select('//div[contains(@class, "item-list")]')
        for link in ilist.select('.//a'):
            url  = link.select('@href').extract()[0]
            if url.find("bioworld.com") == -1:
                url = "http://www.bioworld.com"+url
            yield Request(url, callback=self.parse3)
    
    def parse3(self, response):
        item = BioItem()
        hxs = HtmlXPathSelector(response)
        
        h1 = hxs.select('//h1[contains(@class, "title")]')
        title = h1.select('text()').extract()[0]
        title = title.replace("\n", "")
        title = title.replace("\t", "")
        item['title'] = title
        
        div = hxs.select('//div[contains(@class, "timestamp")]')
        date = div.select('text()').extract()[0]
        item['date'] = date
        
        div = hxs.select('//div[@id="content-area"]')
        txt = ""
        for p in div.select('.//p'):
            txt += p.extract()
        item['text'] = txt
        
        return item
