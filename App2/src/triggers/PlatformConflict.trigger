trigger PlatformConflict on Platform_Of_Route__c (before insert) {
	public List<Platform_Of_Route__c> allPlatformList; 
	public List<Platform__c> platform;
	
	allPlatformList = [SELECT id, Arrival_Time__c, Departure_Time__c, Platform__c FROM Platform_Of_Route__c];
	Integer cos = Trigger.New.size();
	system.debug(cos);
	
	for(Platform_Of_Route__c p : Trigger.New) {
		for(Platform_Of_Route__c pl : allPlatformList) {
			if ((p.Arrival_Time__c >= pl.Arrival_Time__c) && (p.Arrival_Time__c <= pl.Departure_Time__c ) && (p.Platform__c == pl.Platform__c)) {
				platform = [SELECT id, Name, Platform_Number__c, Station__r.Name FROM Platform__c WHERE id = :p.Platform__c LIMIT 1];
				p.addError('Platform number ' + platform[0].Platform_Number__c + ' in station ' + platform[0].Station__r.Name  + ' is use at this time.');
				break;
			}
		}
	}
	system.debug(Trigger.New);
}