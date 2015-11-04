public with sharing class PackageCtrl {
	public Package__c pack { get;public set; }
	public String addressee { get;public set; }
	public String sender { get;public set; }
	public String weight { get;public set; }
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
		if (addressee.isAlphanumeric() && sender.isAlphanumeric() && addressee != '' && sender != '' && !addressee.isNumeric() && !sender.isNumeric()){
				pack.Addressee__c = addressee;
				pack.Sender__c = sender;
				if (weight.isNumeric()){
					if(Integer.valueOf(weight) > 0){
						pack.Weight__c = Integer.valueOf(weight);
						return Page.PackagesPDF;
					}		
				}else {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Mass can be only number and greater than 0!'));		
				}	
		}else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Addressee and Sender can not consist of only digits or be Blank!'));
		}
		return null;	
	}
	public PageReference backToMain() {
		return Page.FindRoute;
	}
}