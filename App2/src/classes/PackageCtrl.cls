public with sharing class PackageCtrl {
	public Package__c pack { get;public set; }
	public String addressee { get;public set; }
	public String sender { get;public set; }
	public Double weight { get;public set; }
	public Boolean wahehouse { get;public set; }
	public String ciFrom { get;public set; }
	public String ciTo { get;public set; }
	
	public PackageCtrl() {
		pack = new Package__c();
	}
	
	public PageReference printToPDF() {
		ciFrom = pack.From__r.Name;
		ciTo = pack.To__r.Name;
		return Page.PackagesPDF;
	}
	public PageReference backToMain() {
		return Page.FindRoute;
	}
}

/* 
insert pack;
		pack.Addressee__c = addressee;
		pack.Sender__c = sender;
		pack.Weight__c = weight;
		pack.Warehouse__c = wahehouse;
		pack.From__c = ciFrom;
		pack.To__c = ciTo;
		
[SELECT Addressee__c, Sender__c, Weight__c, Warehouse__c,From__c, To__c FROM Package__c WHERE Addressee__c = :addressee AND Sender__c = :sender AND Weight__c = :weight LIMIT 1];
		
*/