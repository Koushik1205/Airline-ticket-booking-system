@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Airline Booking Header Consumption View'
@Search.searchable: true
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZCIT_CBKHDR_AM022
  provider contract transactional_query
  as projection on ZCIT_IBKHDR_AM022
{
  key BookingId,
  PassengerName,
  PassengerEmail,
  FlightDate,
  DepartureCode,
  ArrivalCode,
  AirlineCode,
  AirlineName,
  @Search.defaultSearchElement: true
  BookingStatus,
  @Semantics.amount.currencyCode: 'Currency'
  TotalFare,
  Currency,
  LocalCreatedBy,
  LocalCreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
 
  /* Associations */
  _bookingitem : redirected to composition child ZCIT_CBKITM_AM022
}
