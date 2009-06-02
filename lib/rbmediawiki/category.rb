#This class represents a category and performs actions dealing with categories.
#
class Category
    attr_reader :title
    attr_reader :id
    def initialize(title = nil, site = nil, id = nil)
        @site = site ? site : Api.new()
        @title = title.gsub(" ","_")
        @id = id
    end

    #get pages in the category as an array of Page elements
    #returns false if there aren't any, and raises NoPage if page doesn't exist
    def get_members(cmlimit = 500)
        cmcontinue = nil
        cms = Array.new
        loop {
            result = @site.query_list_categorymembers(@title, @title, nil, nil, cmcontinue, cmlimit)
            if result.key?('error')
                raise NoPage.new(), "Page [[#{@title}]] does not exist"
            end
            if result['query']['categorymembers']['cm'].is_a? Array
                cms = cms + result['query']['categorymembers']['cm']
            else
                cms.push(result['query']['categorymembers']['cm'])
            end
            if result.key?('query-continue')
                cmcontinue = result['query-continue']['categorymembers']['cmcontinue']
            else
                break
            end
        }
        return cms
    end
end
