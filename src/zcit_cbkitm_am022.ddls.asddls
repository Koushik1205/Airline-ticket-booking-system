@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Airline Booking Item Consumption View'
@Search.searchable: true
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZCIT_CBKITM_AM022
  as projection on ZCIT_IBKITM_AM022
{
  key BookingId,
  key ItemNumber,
  @Search.defaultSearchElement: true
  FlightNumber,
  DepartureTime,
  ArrivalTime,
  SeatClass,
  SeatNumber,
  BaggageAllowance,
  @Semantics.amount.currencyCode: 'Currency'
  FareAmount,
  Currency,
  LocalCreatedBy,
  LocalCreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
 
  /* Associations */
  _bookingHeader : redirected to parent ZCIT_CBKHDR_AM022
}
