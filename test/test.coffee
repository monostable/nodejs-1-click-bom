{expect} = require('chai')
{parseTSV, writeTSV} = require('./../lib/main')
line_data = require('./../lib/main').lineData

describe 'parseTSV', () ->
    it 'catches negative quantities', () ->
        {lines, invalid} = parseTSV('References\tQty\tFarnell\ntest\t-1\t898989')
        expect(lines.length).to.equal(0)
        expect(invalid[0].reason).to.equal('Quantity is less than one.')

    it 'replaces dashes', () ->
        {lines, invalid} = parseTSV('References\tQty\tFarnell\ntest\t1\t8-98-989')
        expect(lines[0].retailers.Farnell).to.equal('898989')

    it "doesn't replace dashes for Digikey", () ->
        {lines, invalid} = parseTSV('References\tQty\tDigikey\ntest\t1\t8-98-989')
        expect(lines[0].retailers.Digikey).to.equal('8-98-989')

    it 'trims whitespace', () ->
        {lines, invalid} = parseTSV('References\tQty\tDigikey\tFarnell\n test \t1\t 898989 \t`')
        expect(lines[0].retailers.Digikey).to.equal('898989')
        expect(lines[0].reference).to.equal('test')

    it 'adds manufacturer to part number', () ->
        {lines, invalid} = parseTSV('References\tQty\tManufacturer\tPart\ntest\t1\tman\tmpn1\t`')
        expect(lines[0].partNumbers[0]).to.equal('man mpn1')

    it 'handles multiple part numbers', () ->
        {lines, invalid} = parseTSV('References\tQty\tPart\tPart\ntest\t1\tmpn1\tmpn2')
        expect(lines[0].partNumbers).to.deep.equal(['mpn1', 'mpn2'])

    it "doesn't add empty part numbers", () ->
        {lines, invalid} = parseTSV('References\tQty\tPart\tPart\ntest\t1\t\t')
        expect(lines[0].partNumbers.length).to.equal(0)

describe 'writeTSV', () ->
    it 'writes out multiple part numbers', () ->
        test_string = 'References\tQty\tDescription\tPart Number\tPart Number'
        for retailer in line_data.retailer_list
            test_string += '\t' + retailer
        test_string += '\ntest\t1\tdescr\tmpn1\tmpn2'
        for _ in line_data.retailer_list
            test_string += '\t'
        test_string += '\n'
        {lines, invalid} = parseTSV(test_string)
        expect(writeTSV(lines)).to.equal(test_string)

describe 'line_data.numberOfEmpty', () ->
    it 'counts retailers as empty fields', () ->
        {lines, invalid} = parseTSV('References\tQty\tPart\ntest\t1\tmpn1\n')
        expect(line_data.numberOfEmpty(lines)).to.equal(line_data.retailer_list.length)

    it 'counts empty part numbers as empty fields', () ->
        {lines, invalid} = parseTSV('References\tQty\tFarnell\ntest\t1\t898989\n')
        expect(line_data.numberOfEmpty(lines)).to.equal(line_data.retailer_list.length)

    it "doesn't count extra part numbers as empty fields", () ->
        {lines, invalid} = parseTSV('References\tQty\tFarnell\tPart\tPart\ntest\t1\t898989\t\t\n')
        expect(line_data.numberOfEmpty(lines)).to.equal(line_data.retailer_list.length)

