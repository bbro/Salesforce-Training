public class TimetableAtTheStation {
	
	public Station__c station { get; set; }	
	public String nameStation { get; set; }
	public Date searchDate { get;set; }
	public Time searchTime { get; set; }
	public List<Platform_Of_Route__c> timetable { get; set; }
	public ID stationId { get; set; }
	public String stationName { set; get; }
	public List<SelectOption> stationsOptions;
			
	public TimetableAtTheStation() {
		if(station == null) {
			system.debug('!!!');
			station = new Station__c();
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
		PageReference outPage = Page.TimetableAtTheStationList;
		DateTime travelDateTime = DateTime.newinstance(searchDate.year(), searchDate.month(), searchDate.day(), searchTime.hour(), searchTime.minute(), searchTime.second());
		timetable = [SELECT Id, Platform__r.Station__r.Id, Arrival_Time__c, Departure_Time__c, Platform__r.Station__r.name, Platform__r.Platform_Number__c, Route__r.name 
					FROM Platform_Of_Route__c 	
					WHERE ((Platform__r.Station__r.Id = :stationId) AND (Departure_Time__c >= :travelDateTime)) ];
		system.debug(stationId);
		return outPage;
	} 
	
	public PageReference BackToTimetable() {
		PageReference outPage = Page.TimetableAtTheStation;
		return outPage;
	}
}