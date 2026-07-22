# Copyright 2020-2025 Ian Greenhoe
require 'csv'

# Spreadsheet class represents a spreadsheet (in-memory version of a .csv file)
class Spreadsheet
    attr_reader :dy
    attr_reader :dx

    def initialize
        @sheet = []
        @dy = 0
        @dx = 0
    end

    def length
        @sheet.length
    end

    def width(row = nil)
        unless row.nil?
            return row < 0 || @sheet[row].nil? ? 0 : @sheet[row].length
        end

        row = @sheet.max { |a, b| a.length <=> b.length }
        row.length
    end

    def dy=(value)
        throw "Bad coordinate #{value}" unless value.is_a? Integer and value >= 0
        @dy = value
    end

    def dx=(value)
        throw "Bad coordinate #{value}" unless value.is_a? Integer and value >= 0
        @dx = value
    end

    def set(x, y, value)
        throw "Bad coordinate (#{x},#{y}) with delta (#{@dx},#{dy})" unless y.is_a? Integer and y + @dy >= 0
        throw "Bad coordinate (#{x},#{y}) with delta (#{@dx},#{dy})" unless x.is_a? Integer and x + @dx >= 0

        getRow(y + @dy)[x + @dx] = value
    end

    def setRow(x, y, array)
        unless array.is_a? Array
            set(x, y, array)
            return
        end

        throw "Bad coordinate (#{x},#{y}) with delta (#{@dx},#{dy})" unless y.is_a? Integer and y + @dy >= 0
        throw "Bad coordinate (#{x},#{y}) with delta (#{@dx},#{dy})" unless x.is_a? Integer and x + @dx >= 0

        start = x + @dx
        finish = start + array.length
        getRow(y + @dy)[start...finish] = array
    end

    def get(x, y)
        throw "Bad coordinate (#{x},#{y}) with delta (#{@dx},#{dy})" unless y.is_a? Integer and y + @dy >= 0
        throw "Bad coordinate (#{x},#{y}) with delta (#{@dx},#{dy})" unless x.is_a? Integer and x + @dx >= 0

        getRow(y + @dy)[x + @dx]
    end

    def to_csv
        length = @sheet.length

        CSV.generate do |csv|
            (0...length).each do |index|
                csv << getRow(index)
            end
        end
    end

    def from_csv(str)
        index = 0
        @sheet.clear

        CSV.parse(str) do |csv|
            row = getRow(index)
            row[0..row.length] = csv
            index += 1
        end
    end

    private

    def getRow(index)
        row = @sheet[index]
        @sheet[index] = row = [] if row.nil?
        row
    end
end
