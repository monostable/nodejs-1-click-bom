exports.retailer_list = ['Digikey', 'Mouser', 'RS', 'Newark', 'Farnell']
exports.field_list = ['partNumber', 'manufacturer', 'description']
exports.isComplete = (lines) ->
    complete = true
    for line in lines
        for r in exports.retailer_list
            if line.retailers[r] == ''
                complete = false
                break
        if not complete
            break
        for f in exports.field_list
            if line[f] == ''
                complete = false
                break
    return complete

exports.hasSKUs = (lines) ->
    hasSKUs = false
    for line in lines
        for r in exports.retailer_list
            if line.retailers[r] != ''
                hasSKUs = true
                break
        if hasSKUs
            break
    return hasSKUs
