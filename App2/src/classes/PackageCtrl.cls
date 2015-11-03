public with sharing class PackageCtrl {
	public Package__c pack { get;public set; }
	public String addressee { get;public set; }
	public String sender { get;public set; }
	public Double weight { get;public set; }
	public Boolean wahehouse { get;public set; }
	public String ciFrom { get;public set; }
	public String ciTo { get;public set; }
	public Id routeId = ApexPages.currentPage().getParameters().get('routeToSendPackageOnId');
	public List<Train_on_Route__c> foundTrainsOnRoute { get; set;}
	
	public PackageCtrl() {
		pack = new Package__c();
		routeId = ApexPages.currentPage().getParameters().get('routeToSendPackageOnId');
		ciFrom = ApexPages.currentPage().getParameters().get('stationFromName');
		ciTo = ApexPages.currentPage().getParameters().get('stationToName');
		foundTrainsOnRoute = [SELECT Route__r.Name, Train__r.Name FROM Train_On_Route__c WHERE Route__r.Id = :routeId];
	}
	
	public PageReference printToPDF() {
		pack.Addressee__c = addressee;
		pack.Sender__c = sender;
		pack.Weight__c = weight;
		return Page.PackagesPDF;
	}
	public PageReference backToMain() {
		return Page.FindRoute;
	}
}