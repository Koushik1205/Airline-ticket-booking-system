@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Child Interface View - Booking Item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZCIT_IBKITM_AM022
  as select from zcit_bkitm_am022
  association to parent ZCIT_IBKHDR_AM022 as _bookingHeader
    on $projection.BookingId = _bookingHeader.BookingId
{
  key bookingid            as BookingId,
  key itemnumber           as ItemNumber,
  flightnumber             as FlightNumber,
  departuretime            as DepartureTime,
  arrivaltime              as ArrivalTime,
  seatclass                as SeatClass,
  seatnumber               as SeatNumber,
  baggageallowance         as BaggageAllowance,
  @Semantics.amount.currencyCode: 'Currency'
  fareamount               as FareAmount,
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
  _bookingHeader
}
