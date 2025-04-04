INSERT INTO j_purchaseorder
VALUES (
SYS_GUID(),
trunc(sysdate),
'{"PONumber" : 1600,"Reference" : "ABULL-20140421","Requestor" : "Alexis Bull","User" : "ABULL","CostCenter" : "A50",
"ShippingInstructions" :{"name" : "Alexis Bull","Address" : {"street" : "200 Sporting Green",
"city" : "South San Francisco","state" : "CA","zipCode" : 99236,
"country" : "United States of America"},
"Phone" : [{"type" : "Office", "number" : "909-555-7307"},{"type" : "Mobile", "number" : "415-555-1234"}]},
"Special Instructions" : null,"AllowPartialShipment" : true,"LineItems" :[
{"ItemNumber" : 1, "Part" : {"Description" : "One Magic Christmas","UnitPrice" : 19.95,"UPCCode" : 13131092899}, "Quantity" : 9.0},
{"ItemNumber" : 2, "Part" : {"Description" : "Lethal Weapon","UnitPrice" : 19.95,"UPCCode" : 85391628927}, "Quantity" : 5.0}]
}'
);

INSERT INTO j_purchaseorder
VALUES (
SYS_GUID(),
trunc(sysdate),
'{"PONumber" : 672,
"Reference" : "SBELL-20141017",
"Requestor" : "Sarah Bell",
"User" : "SBELL",
"CostCenter" : "A50",
"ShippingInstructions" : {"name" : "Sarah Bell",
"Address" : {"street" : "200 Sporting Green",
"city" : "South San Francisco",
"state" : "CA",
"zipCode" : 99236,
"country" : "United States of America"},
"Phone" : "983-555-6509"},
"Special Instructions" : "Courier",
"LineItems" :
[{"ItemNumber" : 1,
"Part" : {"Description" : "Making the Grade",
"UnitPrice" : 20,
"UPCCode" : 27616867759},
"Quantity" : 8.0},
{"ItemNumber" : 2,
"Part" : {"Description" : "Nixon",
"UnitPrice" : 19.95,
"UPCCode" : 717951002396},
"Quantity" : 5},
{"ItemNumber" : 3,
"Part" : {"Description" : "Eric Clapton: Best Of 1981-1999",
"UnitPrice" : 19.95,
"UPCCode" : 75993851120},
"Quantity" : 5.0}]}');