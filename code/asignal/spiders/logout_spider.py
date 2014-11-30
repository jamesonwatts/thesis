from scrapy.spider import BaseSpider
from scrapy.http import Request

class LogoutSpider(BaseSpider):
    name = "logout"
    allowed_domains = ["bioworld.com"]
    start_urls = ['http://www.bioworld.com/logout']
        
    def parse(self, response):
        if "My Account" in response.body:
            return Request("http://www.bioworld.com/logout", callback=self.done)
        else:
            print "DONE!"
    
    def done(self, response):
        print("NOW ALL DONE")
