@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root Interface View - Booking Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZCIT_IBKHDR_AM022
  as select from zcit_bkhdr_am022 as BookingHeader
  composition [0..*] of ZCIT_IBKITM_AM022 as _bookingitem
{
  key bookingid            as BookingId,
  passengername            as PassengerName,
  passengeremail           as PassengerEmail,
  flightdate               as FlightDate,
  departurecode            as DepartureCode,
  arrivalcode              as ArrivalCode,
  airlinecode              as AirlineCode,
  airlinename              as AirlineName,
  bookingstatus            as BookingStatus,
  @Semantics.amount.currencyCode: 'Currency'
  totalfare                as TotalFare,
  currency                 as Currency,
  @Semantics.user.createdBy: true
  local_created_by         as LocalCreatedBy,
  @Semantics.systemDateTime.createdAt: true
  local_created_at         as LocalCreatedAt,
  @Semantics.user.lastChangedBy: true
  local_last_changed_by    as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at    as LocalLastChangedAt,
 
  /* Associations */
  _bookingitem
}
