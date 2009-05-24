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
        cms = Hash.new
        loop {
            result = @site.query_list_categorymembers(@title, @title, nil, nil, cmcontinue, cmlimit)
            if result.key?('query-continue')
                cmcontinue = result['query-continue']['categorymembers']['cmcontinue']
                cms.deep_merge!(result['query'])
            else
                cms.deep_merge!(result['query'])
                break
            end
        }
        if cms['pages']['page'].key?('missing')
            raise NoPage.new(), "Page [[#{title}]] does not exist"
        elsif cms.key?('categorymembers')
            members = Array.new
            cms['categorymembers']['cm'].each{|el| members.push(Page.new(el['title']))}
            return members
        else return false
        end

    end
end
