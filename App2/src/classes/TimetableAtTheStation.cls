public class TimetableAtTheStation {
	public Station__c station { get; set; }	
	public String nameStation { get; set; }
	public Date searchDate { get; set; }
	public Time searchTime { get; set; }
	public List<Platform_Of_Route__c> timetable { get; set; }
	public List<Platform_Of_Route__c> detailsOfRoute { get; set; }
	public Id stationId { get; set; }
	public Id routeId { get; set; }
	public String stationName { set; get; }
	public List<SelectOption> stationsOptions;
			
	public TimetableAtTheStation() {
		if(station == null) {
			station = new Station__c();
		}
		if (this.searchDate == null) {
			this.searchDate = Date.today();
		}
		if (this.searchTime == null) {
			this.searchTime = DateTime.now().time();
		}
	}
	
	public List<SelectOption> getStationsOptions() {
        stationsOptions = new List<SelectOption>();
        for(Station__c station : [SELECT Id, Name FROM Station__c]) {
	        stationsOptions.add(new SelectOption(station.Id, station.Name));       
        }
        return stationsOptions;
    }
	
	public PageReference showTimetable(){
		PageReference outPage = null;
		if (searchDate == null || searchTime == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Fill in date and time!'));
		}
		else {
			DateTime travelDateTime = DateTime.newinstance(searchDate.year(), searchDate.month(), searchDate.day(), searchTime.hour(), searchTime.minute(), searchTime.second());
			timetable = [SELECT Id, Platform__r.Station__r.Id, Arrival_Time__c, Departure_Time__c, Platform__r.Station__r.Name, Platform__r.Platform_Number__c, Route__r.Name 
					     FROM Platform_Of_Route__c 	
					     WHERE ((Platform__r.Station__r.Id = :stationId) AND (Departure_Time__c >= :travelDateTime))];
			if (timetable.size()==0) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No results found.'));
			}
			else {
				outPage = Page.TimetableAtTheStationList;
			}
		}
		return outPage;
	} 
	
	public PageReference toRouteDetails() {
    	detailsOfRoute = [SELECT Arrival_Time__c, Departure_Time__c, Platform__c, Station_Number__c, Platform__r.Station__r.Name, Route__c FROM Platform_Of_Route__c WHERE Route__r.Id = :routeId];
    	PageReference routeDetailsPage = Page.RouteDetails;
    	return routeDetailsPage;
    }
    
	public PageReference BackToTimetable() {
		PageReference outPage = Page.TimetableAtTheStation;
		return outPage;
	}
}