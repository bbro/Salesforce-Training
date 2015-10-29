public with sharing class FindRouteCtrl {
	public Id startStationId { get; set; }
	public Id endStationId { get; set; }
	public Time travelTime { 
        get {
            if (travelTime == null) {
                travelTime =  DateTime.now().time();
            }
            return travelTime;
        }
        set;
    }
    public Time arrivalTime { get; set; }
    public Time departureTime { get; set; }
    public Date departureDate {
    	get {
    		if (departureDate == null) {
    			departureDate = Date.today();
    		}
    		return departureDate;
    	}
    	set;
    }
	public String typeOfTrain { get; set; }
	public Boolean isArrivalTime { get; set; }
	public Boolean inBetweenStations { get; set; }
	public Boolean hasDisabledSupport { get; set; }
	public Boolean canTransportBicycles { get; set; }
	public Boolean packagesAvailable { get; set; }
	public Train__c train { get; set; }
	
	public FindRouteCtrl() {
		this.train = new Train__c();
	}
	public List<SelectOption> getStationsOptions() {
        List<SelectOption> stationsOptions = new List<SelectOption>();
        for(Station__c station : [SELECT Id, Name FROM Station__c]) {
	        stationsOptions.add(new SelectOption(station.Id, station.Name));
        }
        return stationsOptions;
    }
}