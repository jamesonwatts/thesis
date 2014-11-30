from scrapy.spider import BaseSpider
from scrapy.selector import HtmlXPathSelector
from scrapy.http import Request
from scrapy.http import FormRequest
from asignal.items import BioItem

class InsightSpider(BaseSpider):
    name = "insight"
    allowed_domains = ["bioworld.com"]
    start_urls = ['http://www.bioworld.com/node?destination=node']
        
    def parse(self, response):
        return [FormRequest.from_response(response,formdata={'name': 'jamesonw', 'pass': 'alwaysHumbl3/'}, callback=self.after_login)]
    
    def after_login(self, response):
        if "My Account" in response.body:
            yield Request("http://www.bioworld.com/bioworld/insight/archive/list/", callback=self.parse1)
        else:
            print "BUMMER!"
    

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
