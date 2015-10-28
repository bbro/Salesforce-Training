public with sharing class PackageCtrl {
	public Package__c pack { get; set; }
	public String addressee { get; set; }
	public String sender { get; set; }
	public Double weight { get; set; }
	
	public PackageCtrl() {
		Package__c pack = new Package__c();
	}
	
	public PageReference printToPDF() {
//		Pagereference pgref = new Pagereference('/apex/PackagesPDF');
	//	Blob pdfPageBlob;
	//	pdfPageBlob = pgref.getContentAsPDF();
	//	pgref.setRedirect(True);
		return null;
	//	Apexpages.currentPage().getContentAsPDF();
	}
}