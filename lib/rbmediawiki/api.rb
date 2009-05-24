#coding: utf-8

Ourconfig = YAML::load(File.open(File.dirname(__FILE__)+"/config.yml"))

# This class provides an interface for the MediaWiki API.
# Methods match specific queries to the API, and so the meaning of the 
# parameters are described in http://www.mediawiki.org/wiki/API
#
# It is intended to be used as a base layer to build specific methods on top 
# of it
#
# Only four methods are special and deserve comments here: #new, #login, #query and #add_post
class Api

# * lang: language of the wiki at wikimedia.
# * family: family of the wiki at wikimedia. If the wiki is not language dependant, as commons.wikimedia.org , lang value is ignored.
# * user: user to make the edits
# * server: the url of the server, as in http://en.wikipedia.org this parameter overrides lang and family values
# * api_url: the url of the api, as in http://en.wikipedia.org if not specified, it will be guessed from the lang+family values or the server
    def initialize(lang = nil, family = nil, user = nil, server = nil, api_url = nil)
        @config = Hash.new 
        @config['base_url'] = server
        @config['api_url'] = api_url
        @config['logged'] = false
        @config['user'] = user ? user : Ourconfig['default_user'] 
    end

    def api_url
        return @config['api_url']
    end

    def base_url
        return @config['base_url']
    end

    #Asks for a password and tries to log in. Stores the resulting cookies 
    #for using then when making requests. If the user is already logged iy
    #does nothing

    def login(password = nil)
        if @config['logged']
            return true
        end
        if (!password)
            puts "Introduce password for #{@config['user']} at #{@config['base_url']}"
            password = gets.chomp
        end

        post_me = add_post('lgname',@config['user'])
        post_me = add_post('lgpassword',password, post_me)
        post_me = add_post('action', 'login', post_me)

        login_result = make_request(post_me)

        @config['lgusername']  = login_result['login']['lgusername']
        @config['lguserid']    = login_result['login']['lguserid']
        @config['lgtoken'] 	   = login_result['login']['lgtoken']
        @config['_session']    = login_result['login']['sessionid']
  	    @config['cookieprefix']= login_result['login']['cookieprefix']

        @config['logged'] = true

        return @cookie
    end
  
    def query_prop_categories(titles = nil, clprop = nil, clshow = nil, cllimit = nil, clcontinue = nil, clcategories = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('clprop', clprop, post_me)
        post_me = add_post('clshow', clshow, post_me)
        post_me = add_post('cllimit', cllimit, post_me)
        post_me = add_post('clcontinue', clcontinue, post_me)
        post_me = add_post('clcategories', clcategories, post_me)
        post_me = add_post('prop', 'categories', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_prop_images(titles = nil, imlimit = nil, imcontinue = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('imlimit', imlimit, post_me)
        post_me = add_post('imcontinue', imcontinue, post_me)
        post_me = add_post('prop', 'images', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_prop_revisions(titles = nil, rvprop = nil, rvlimit = nil, rvstartid = nil, rvendid = nil, rvstart = nil, rvend = nil, rvdir = nil, rvuser = nil, rvexcludeuser = nil, rvexpandtemplates = nil, rvgeneratexml = nil, rvsection = nil, rvtoken = nil, rvcontinue = nil, rvdiffto = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('rvprop', rvprop, post_me)
        post_me = add_post('rvlimit', rvlimit, post_me)
        post_me = add_post('rvstartid', rvstartid, post_me)
        post_me = add_post('rvendid', rvendid, post_me)
        post_me = add_post('rvstart', rvstart, post_me)
        post_me = add_post('rvend', rvend, post_me)
        post_me = add_post('rvdir', rvdir, post_me)
        post_me = add_post('rvuser', rvuser, post_me)
        post_me = add_post('rvexcludeuser', rvexcludeuser, post_me)
        post_me = add_post('rvexpandtemplates', rvexpandtemplates, post_me)
        post_me = add_post('rvgeneratexml', rvgeneratexml, post_me)
        post_me = add_post('rvsection', rvsection, post_me)
        post_me = add_post('rvtoken', rvtoken, post_me)
        post_me = add_post('rvcontinue', rvcontinue, post_me)
        post_me = add_post('rvdiffto', rvdiffto, post_me)
        post_me = add_post('prop', 'revisions', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_meta_siteinfo(titles = nil, siprop = nil, sifilteriw = nil, sishowalldb = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('siprop', siprop, post_me)
        post_me = add_post('sifilteriw', sifilteriw, post_me)
        post_me = add_post('sishowalldb', sishowalldb, post_me)
        post_me = add_post('meta', 'siteinfo', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_list_exturlusage(titles = nil, euprop = nil, euoffset = nil, euprotocol = nil, euquery = nil, eunamespace = nil, eulimit = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('euprop', euprop, post_me)
        post_me = add_post('euoffset', euoffset, post_me)
        post_me = add_post('euprotocol', euprotocol, post_me)
        post_me = add_post('euquery', euquery, post_me)
        post_me = add_post('eunamespace', eunamespace, post_me)
        post_me = add_post('eulimit', eulimit, post_me)
        post_me = add_post('list', 'exturlusage', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_list_allpages(titles = nil, apfrom = nil, apprefix = nil, apnamespace = nil, apfilterredir = nil, apminsize = nil, apmaxsize = nil, apprtype = nil, apprlevel = nil, apprfiltercascade = nil, aplimit = nil, apdir = nil, apfilterlanglinks = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('apfrom', apfrom, post_me)
        post_me = add_post('apprefix', apprefix, post_me)
        post_me = add_post('apnamespace', apnamespace, post_me)
        post_me = add_post('apfilterredir', apfilterredir, post_me)
        post_me = add_post('apminsize', apminsize, post_me)
        post_me = add_post('apmaxsize', apmaxsize, post_me)
        post_me = add_post('apprtype', apprtype, post_me)
        post_me = add_post('apprlevel', apprlevel, post_me)
        post_me = add_post('apprfiltercascade', apprfiltercascade, post_me)
        post_me = add_post('aplimit', aplimit, post_me)
        post_me = add_post('apdir', apdir, post_me)
        post_me = add_post('apfilterlanglinks', apfilterlanglinks, post_me)
        post_me = add_post('list', 'allpages', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_meta_allmessages(titles = nil, ammessages = nil, amfilter = nil, amlang = nil, amfrom = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('ammessages', ammessages, post_me)
        post_me = add_post('amfilter', amfilter, post_me)
        post_me = add_post('amlang', amlang, post_me)
        post_me = add_post('amfrom', amfrom, post_me)
        post_me = add_post('meta', 'allmessages', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_list_protectedtitles(titles = nil, ptnamespace = nil, ptlevel = nil, ptlimit = nil, ptdir = nil, ptstart = nil, ptend = nil, ptprop = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('ptnamespace', ptnamespace, post_me)
        post_me = add_post('ptlevel', ptlevel, post_me)
        post_me = add_post('ptlimit', ptlimit, post_me)
        post_me = add_post('ptdir', ptdir, post_me)
        post_me = add_post('ptstart', ptstart, post_me)
        post_me = add_post('ptend', ptend, post_me)
        post_me = add_post('ptprop', ptprop, post_me)
        post_me = add_post('list', 'protectedtitles', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_list_deletedrevs(titles = nil, drstart = nil, drend = nil, drdir = nil, drfrom = nil, drcontinue = nil, drunique = nil, druser = nil, drexcludeuser = nil, drnamespace = nil, drlimit = nil, drprop = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('drstart', drstart, post_me)
        post_me = add_post('drend', drend, post_me)
        post_me = add_post('drdir', drdir, post_me)
        post_me = add_post('drfrom', drfrom, post_me)
        post_me = add_post('drcontinue', drcontinue, post_me)
        post_me = add_post('drunique', drunique, post_me)
        post_me = add_post('druser', druser, post_me)
        post_me = add_post('drexcludeuser', drexcludeuser, post_me)
        post_me = add_post('drnamespace', drnamespace, post_me)
        post_me = add_post('drlimit', drlimit, post_me)
        post_me = add_post('drprop', drprop, post_me)
        post_me = add_post('list', 'deletedrevs', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_prop_imageinfo(titles = nil, iiprop = nil, iilimit = nil, iistart = nil, iiend = nil, iiurlwidth = nil, iiurlheight = nil, iicontinue = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('iiprop', iiprop, post_me)
        post_me = add_post('iilimit', iilimit, post_me)
        post_me = add_post('iistart', iistart, post_me)
        post_me = add_post('iiend', iiend, post_me)
        post_me = add_post('iiurlwidth', iiurlwidth, post_me)
        post_me = add_post('iiurlheight', iiurlheight, post_me)
        post_me = add_post('iicontinue', iicontinue, post_me)
        post_me = add_post('prop', 'imageinfo', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_list_blocks(titles = nil, bkstart = nil, bkend = nil, bkdir = nil, bkids = nil, bkusers = nil, bkip = nil, bklimit = nil, bkprop = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('bkstart', bkstart, post_me)
        post_me = add_post('bkend', bkend, post_me)
        post_me = add_post('bkdir', bkdir, post_me)
        post_me = add_post('bkids', bkids, post_me)
        post_me = add_post('bkusers', bkusers, post_me)
        post_me = add_post('bkip', bkip, post_me)
        post_me = add_post('bklimit', bklimit, post_me)
        post_me = add_post('bkprop', bkprop, post_me)
        post_me = add_post('list', 'blocks', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_list_alllinks(titles = nil, alcontinue = nil, alfrom = nil, alprefix = nil, alunique = nil, alprop = nil, alnamespace = nil, allimit = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('alcontinue', alcontinue, post_me)
        post_me = add_post('alfrom', alfrom, post_me)
        post_me = add_post('alprefix', alprefix, post_me)
        post_me = add_post('alunique', alunique, post_me)
        post_me = add_post('alprop', alprop, post_me)
        post_me = add_post('alnamespace', alnamespace, post_me)
        post_me = add_post('allimit', allimit, post_me)
        post_me = add_post('list', 'alllinks', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_meta_userinfo(titles = nil, uiprop = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('uiprop', uiprop, post_me)
        post_me = add_post('meta', 'userinfo', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_list_random(titles = nil, rnnamespace = nil, rnlimit = nil, rnredirect = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('rnnamespace', rnnamespace, post_me)
        post_me = add_post('rnlimit', rnlimit, post_me)
        post_me = add_post('rnredirect', rnredirect, post_me)
        post_me = add_post('list', 'random', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_list_categorymembers(titles = nil, cmtitle = nil, cmprop = nil, cmnamespace = nil, cmcontinue = nil, cmlimit = nil, cmsort = nil, cmdir = nil, cmstart = nil, cmend = nil, cmstartsortkey = nil, cmendsortkey = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('cmtitle', cmtitle, post_me)
        post_me = add_post('cmprop', cmprop, post_me)
        post_me = add_post('cmnamespace', cmnamespace, post_me)
        post_me = add_post('cmcontinue', cmcontinue, post_me)
        post_me = add_post('cmlimit', cmlimit, post_me)
        post_me = add_post('cmsort', cmsort, post_me)
        post_me = add_post('cmdir', cmdir, post_me)
        post_me = add_post('cmstart', cmstart, post_me)
        post_me = add_post('cmend', cmend, post_me)
        post_me = add_post('cmstartsortkey', cmstartsortkey, post_me)
        post_me = add_post('cmendsortkey', cmendsortkey, post_me)
        post_me = add_post('list', 'categorymembers', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_list_allusers(titles = nil, aufrom = nil, auprefix = nil, augroup = nil, auprop = nil, aulimit = nil, auwitheditsonly = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('aufrom', aufrom, post_me)
        post_me = add_post('auprefix', auprefix, post_me)
        post_me = add_post('augroup', augroup, post_me)
        post_me = add_post('auprop', auprop, post_me)
        post_me = add_post('aulimit', aulimit, post_me)
        post_me = add_post('auwitheditsonly', auwitheditsonly, post_me)
        post_me = add_post('list', 'allusers', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_prop_duplicatefiles(titles = nil, dflimit = nil, dfcontinue = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('dflimit', dflimit, post_me)
        post_me = add_post('dfcontinue', dfcontinue, post_me)
        post_me = add_post('prop', 'duplicatefiles', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_list_watchlist(titles = nil, wlallrev = nil, wlstart = nil, wlend = nil, wlnamespace = nil, wldir = nil, wllimit = nil, wlprop = nil, wlshow = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('wlallrev', wlallrev, post_me)
        post_me = add_post('wlstart', wlstart, post_me)
        post_me = add_post('wlend', wlend, post_me)
        post_me = add_post('wlnamespace', wlnamespace, post_me)
        post_me = add_post('wldir', wldir, post_me)
        post_me = add_post('wllimit', wllimit, post_me)
        post_me = add_post('wlprop', wlprop, post_me)
        post_me = add_post('wlshow', wlshow, post_me)
        post_me = add_post('list', 'watchlist', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_list_search(titles = nil, srsearch = nil, srnamespace = nil, srwhat = nil, srredirects = nil, sroffset = nil, srlimit = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('srsearch', srsearch, post_me)
        post_me = add_post('srnamespace', srnamespace, post_me)
        post_me = add_post('srwhat', srwhat, post_me)
        post_me = add_post('srredirects', srredirects, post_me)
        post_me = add_post('sroffset', sroffset, post_me)
        post_me = add_post('srlimit', srlimit, post_me)
        post_me = add_post('list', 'search', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_list_embeddedin(titles = nil, eititle = nil, eicontinue = nil, einamespace = nil, eifilterredir = nil, eilimit = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('eititle', eititle, post_me)
        post_me = add_post('eicontinue', eicontinue, post_me)
        post_me = add_post('einamespace', einamespace, post_me)
        post_me = add_post('eifilterredir', eifilterredir, post_me)
        post_me = add_post('eilimit', eilimit, post_me)
        post_me = add_post('list', 'embeddedin', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_prop_extlinks(titles = nil, ellimit = nil, eloffset = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('ellimit', ellimit, post_me)
        post_me = add_post('eloffset', eloffset, post_me)
        post_me = add_post('prop', 'extlinks', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_list_globalblocks(titles = nil, bgstart = nil, bgend = nil, bgdir = nil, bgids = nil, bgaddresses = nil, bgip = nil, bglimit = nil, bgprop = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('bgstart', bgstart, post_me)
        post_me = add_post('bgend', bgend, post_me)
        post_me = add_post('bgdir', bgdir, post_me)
        post_me = add_post('bgids', bgids, post_me)
        post_me = add_post('bgaddresses', bgaddresses, post_me)
        post_me = add_post('bgip', bgip, post_me)
        post_me = add_post('bglimit', bglimit, post_me)
        post_me = add_post('bgprop', bgprop, post_me)
        post_me = add_post('list', 'globalblocks', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_list_watchlistraw(titles = nil, wrcontinue = nil, wrnamespace = nil, wrlimit = nil, wrprop = nil, wrshow = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('wrcontinue', wrcontinue, post_me)
        post_me = add_post('wrnamespace', wrnamespace, post_me)
        post_me = add_post('wrlimit', wrlimit, post_me)
        post_me = add_post('wrprop', wrprop, post_me)
        post_me = add_post('wrshow', wrshow, post_me)
        post_me = add_post('list', 'watchlistraw', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_list_usercontribs(titles = nil, uclimit = nil, ucstart = nil, ucend = nil, uccontinue = nil, ucuser = nil, ucuserprefix = nil, ucdir = nil, ucnamespace = nil, ucprop = nil, ucshow = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('uclimit', uclimit, post_me)
        post_me = add_post('ucstart', ucstart, post_me)
        post_me = add_post('ucend', ucend, post_me)
        post_me = add_post('uccontinue', uccontinue, post_me)
        post_me = add_post('ucuser', ucuser, post_me)
        post_me = add_post('ucuserprefix', ucuserprefix, post_me)
        post_me = add_post('ucdir', ucdir, post_me)
        post_me = add_post('ucnamespace', ucnamespace, post_me)
        post_me = add_post('ucprop', ucprop, post_me)
        post_me = add_post('ucshow', ucshow, post_me)
        post_me = add_post('list', 'usercontribs', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_list_logevents(titles = nil, leprop = nil, letype = nil, lestart = nil, leend = nil, ledir = nil, leuser = nil, letitle = nil, lelimit = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('leprop', leprop, post_me)
        post_me = add_post('letype', letype, post_me)
        post_me = add_post('lestart', lestart, post_me)
        post_me = add_post('leend', leend, post_me)
        post_me = add_post('ledir', ledir, post_me)
        post_me = add_post('leuser', leuser, post_me)
        post_me = add_post('letitle', letitle, post_me)
        post_me = add_post('lelimit', lelimit, post_me)
        post_me = add_post('list', 'logevents', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_list_backlinks(titles = nil, bltitle = nil, blcontinue = nil, blnamespace = nil, blfilterredir = nil, bllimit = nil, blredirect = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('bltitle', bltitle, post_me)
        post_me = add_post('blcontinue', blcontinue, post_me)
        post_me = add_post('blnamespace', blnamespace, post_me)
        post_me = add_post('blfilterredir', blfilterredir, post_me)
        post_me = add_post('bllimit', bllimit, post_me)
        post_me = add_post('blredirect', blredirect, post_me)
        post_me = add_post('list', 'backlinks', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_list_allcategories(titles = nil, acfrom = nil, acprefix = nil, acdir = nil, aclimit = nil, acprop = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('acfrom', acfrom, post_me)
        post_me = add_post('acprefix', acprefix, post_me)
        post_me = add_post('acdir', acdir, post_me)
        post_me = add_post('aclimit', aclimit, post_me)
        post_me = add_post('acprop', acprop, post_me)
        post_me = add_post('list', 'allcategories', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_list_allimages(titles = nil, aifrom = nil, aiprefix = nil, aiminsize = nil, aimaxsize = nil, ailimit = nil, aidir = nil, aisha1 = nil, aisha1base36 = nil, aiprop = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('aifrom', aifrom, post_me)
        post_me = add_post('aiprefix', aiprefix, post_me)
        post_me = add_post('aiminsize', aiminsize, post_me)
        post_me = add_post('aimaxsize', aimaxsize, post_me)
        post_me = add_post('ailimit', ailimit, post_me)
        post_me = add_post('aidir', aidir, post_me)
        post_me = add_post('aisha1', aisha1, post_me)
        post_me = add_post('aisha1base36', aisha1base36, post_me)
        post_me = add_post('aiprop', aiprop, post_me)
        post_me = add_post('list', 'allimages', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_prop_info(titles = nil, inprop = nil, intoken = nil, incontinue = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('inprop', inprop, post_me)
        post_me = add_post('intoken', intoken, post_me)
        post_me = add_post('incontinue', incontinue, post_me)
        post_me = add_post('prop', 'info', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_list_users(titles = nil, usprop = nil, ususers = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('usprop', usprop, post_me)
        post_me = add_post('ususers', ususers, post_me)
        post_me = add_post('list', 'users', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_list_recentchanges(titles = nil, rcstart = nil, rcend = nil, rcdir = nil, rcnamespace = nil, rcprop = nil, rctoken = nil, rcshow = nil, rclimit = nil, rctype = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('rcstart', rcstart, post_me)
        post_me = add_post('rcend', rcend, post_me)
        post_me = add_post('rcdir', rcdir, post_me)
        post_me = add_post('rcnamespace', rcnamespace, post_me)
        post_me = add_post('rcprop', rcprop, post_me)
        post_me = add_post('rctoken', rctoken, post_me)
        post_me = add_post('rcshow', rcshow, post_me)
        post_me = add_post('rclimit', rclimit, post_me)
        post_me = add_post('rctype', rctype, post_me)
        post_me = add_post('list', 'recentchanges', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_list_imageusage(titles = nil, iutitle = nil, iucontinue = nil, iunamespace = nil, iufilterredir = nil, iulimit = nil, iuredirect = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('iutitle', iutitle, post_me)
        post_me = add_post('iucontinue', iucontinue, post_me)
        post_me = add_post('iunamespace', iunamespace, post_me)
        post_me = add_post('iufilterredir', iufilterredir, post_me)
        post_me = add_post('iulimit', iulimit, post_me)
        post_me = add_post('iuredirect', iuredirect, post_me)
        post_me = add_post('list', 'imageusage', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_prop_templates(titles = nil, tlnamespace = nil, tllimit = nil, tlcontinue = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('tlnamespace', tlnamespace, post_me)
        post_me = add_post('tllimit', tllimit, post_me)
        post_me = add_post('tlcontinue', tlcontinue, post_me)
        post_me = add_post('prop', 'templates', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_prop_links(titles = nil, plnamespace = nil, pllimit = nil, plcontinue = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('plnamespace', plnamespace, post_me)
        post_me = add_post('pllimit', pllimit, post_me)
        post_me = add_post('plcontinue', plcontinue, post_me)
        post_me = add_post('prop', 'links', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_prop_categoryinfo(titles = nil, cicontinue = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('cicontinue', cicontinue, post_me)
        post_me = add_post('prop', 'categoryinfo', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def query_prop_langlinks(titles = nil, lllimit = nil, llcontinue = nil, pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)
    
        post_me = add_post('lllimit', lllimit, post_me)
        post_me = add_post('llcontinue', llcontinue, post_me)
        post_me = add_post('prop', 'langlinks', post_me)
        post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    def delete(title = nil, pageid = nil, token = nil, reason = nil, watch = nil, unwatch = nil, oldimage = nil, post_me = nil)
    
        post_me = add_post('title', title, post_me)
        post_me = add_post('pageid', pageid, post_me)
        post_me = add_post('token', token, post_me)
        post_me = add_post('reason', reason, post_me)
        post_me = add_post('watch', watch, post_me)
        post_me = add_post('unwatch', unwatch, post_me)
        post_me = add_post('oldimage', oldimage, post_me)
        post_me = add_post('action', 'delete', post_me)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def purge(titles = nil, post_me = nil)
    
        post_me = add_post('titles', titles, post_me)
        post_me = add_post('action', 'purge', post_me)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def parse(title = nil, text = nil, page = nil, redirects = nil, oldid = nil, prop = nil, pst = nil, onlypst = nil, post_me = nil)
    
        post_me = add_post('title', title, post_me)
        post_me = add_post('text', text, post_me)
        post_me = add_post('page', page, post_me)
        post_me = add_post('redirects', redirects, post_me)
        post_me = add_post('oldid', oldid, post_me)
        post_me = add_post('prop', prop, post_me)
        post_me = add_post('pst', pst, post_me)
        post_me = add_post('onlypst', onlypst, post_me)
        post_me = add_post('action', 'parse', post_me)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def expandtemplates(title = nil, text = nil, generatexml = nil, post_me = nil)
    
        post_me = add_post('title', title, post_me)
        post_me = add_post('text', text, post_me)
        post_me = add_post('generatexml', generatexml, post_me)
        post_me = add_post('action', 'expandtemplates', post_me)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def edit(title = nil, section = nil, text = nil, token = nil, summary = nil, minor = nil, notminor = nil, bot = nil, basetimestamp = nil, starttimestamp = nil, recreate = nil, createonly = nil, nocreate = nil, captchaword = nil, captchaid = nil, watch = nil, unwatch = nil, md5 = nil, prependtext = nil, appendtext = nil, undo = nil, undoafter = nil, post_me = nil)
    
        post_me = add_post('title', title, post_me)
        post_me = add_post('section', section, post_me)
        post_me = add_post('text', text, post_me)
        post_me = add_post('token', token, post_me)
        post_me = add_post('summary', summary, post_me)
        post_me = add_post('minor', minor, post_me)
        post_me = add_post('notminor', notminor, post_me)
        post_me = add_post('bot', bot, post_me)
        post_me = add_post('basetimestamp', basetimestamp, post_me)
        post_me = add_post('starttimestamp', starttimestamp, post_me)
        post_me = add_post('recreate', recreate, post_me)
        post_me = add_post('createonly', createonly, post_me)
        post_me = add_post('nocreate', nocreate, post_me)
        post_me = add_post('captchaword', captchaword, post_me)
        post_me = add_post('captchaid', captchaid, post_me)
        post_me = add_post('watch', watch, post_me)
        post_me = add_post('unwatch', unwatch, post_me)
        post_me = add_post('md5', md5, post_me)
        post_me = add_post('prependtext', prependtext, post_me)
        post_me = add_post('appendtext', appendtext, post_me)
        post_me = add_post('undo', undo, post_me)
        post_me = add_post('undoafter', undoafter, post_me)
        post_me = add_post('action', 'edit', post_me)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def watch(title = nil, unwatch = nil, post_me = nil)
    
        post_me = add_post('title', title, post_me)
        post_me = add_post('unwatch', unwatch, post_me)
        post_me = add_post('action', 'watch', post_me)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def protect(title = nil, token = nil, protections = nil, expiry = nil, reason = nil, cascade = nil, watch = nil, post_me = nil)
    
        post_me = add_post('title', title, post_me)
        post_me = add_post('token', token, post_me)
        post_me = add_post('protections', protections, post_me)
        post_me = add_post('expiry', expiry, post_me)
        post_me = add_post('reason', reason, post_me)
        post_me = add_post('cascade', cascade, post_me)
        post_me = add_post('watch', watch, post_me)
        post_me = add_post('action', 'protect', post_me)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def rollback(title = nil, user = nil, token = nil, summary = nil, markbot = nil, post_me = nil)
    
        post_me = add_post('title', title, post_me)
        post_me = add_post('user', user, post_me)
        post_me = add_post('token', token, post_me)
        post_me = add_post('summary', summary, post_me)
        post_me = add_post('markbot', markbot, post_me)
        post_me = add_post('action', 'rollback', post_me)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def feedwatchlist(feedformat = nil, hours = nil, allrev = nil, post_me = nil)
    
        post_me = add_post('feedformat', feedformat, post_me)
        post_me = add_post('hours', hours, post_me)
        post_me = add_post('allrev', allrev, post_me)
        post_me = add_post('action', 'feedwatchlist', post_me)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def patrol(token = nil, rcid = nil, post_me = nil)
    
        post_me = add_post('token', token, post_me)
        post_me = add_post('rcid', rcid, post_me)
        post_me = add_post('action', 'patrol', post_me)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def paraminfo(modules = nil, querymodules = nil, mainmodule = nil, pagesetmodule = nil, post_me = nil)
    
        post_me = add_post('modules', modules, post_me)
        post_me = add_post('querymodules', querymodules, post_me)
        post_me = add_post('mainmodule', mainmodule, post_me)
        post_me = add_post('pagesetmodule', pagesetmodule, post_me)
        post_me = add_post('action', 'paraminfo', post_me)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def move(from = nil, fromid = nil, to = nil, token = nil, reason = nil, movetalk = nil, movesubpages = nil, noredirect = nil, watch = nil, unwatch = nil, post_me = nil)
    
        post_me = add_post('from', from, post_me)
        post_me = add_post('fromid', fromid, post_me)
        post_me = add_post('to', to, post_me)
        post_me = add_post('token', token, post_me)
        post_me = add_post('reason', reason, post_me)
        post_me = add_post('movetalk', movetalk, post_me)
        post_me = add_post('movesubpages', movesubpages, post_me)
        post_me = add_post('noredirect', noredirect, post_me)
        post_me = add_post('watch', watch, post_me)
        post_me = add_post('unwatch', unwatch, post_me)
        post_me = add_post('action', 'move', post_me)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def block(user = nil, token = nil, gettoken = nil, expiry = nil, reason = nil, anononly = nil, nocreate = nil, autoblock = nil, noemail = nil, hidename = nil, allowusertalk = nil, reblock = nil, post_me = nil)
    
        post_me = add_post('user', user, post_me)
        post_me = add_post('token', token, post_me)
        post_me = add_post('gettoken', gettoken, post_me)
        post_me = add_post('expiry', expiry, post_me)
        post_me = add_post('reason', reason, post_me)
        post_me = add_post('anononly', anononly, post_me)
        post_me = add_post('nocreate', nocreate, post_me)
        post_me = add_post('autoblock', autoblock, post_me)
        post_me = add_post('noemail', noemail, post_me)
        post_me = add_post('hidename', hidename, post_me)
        post_me = add_post('allowusertalk', allowusertalk, post_me)
        post_me = add_post('reblock', reblock, post_me)
        post_me = add_post('action', 'block', post_me)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def emailuser(target = nil, subject = nil, text = nil, token = nil, ccme = nil, post_me = nil)
    
        post_me = add_post('target', target, post_me)
        post_me = add_post('subject', subject, post_me)
        post_me = add_post('text', text, post_me)
        post_me = add_post('token', token, post_me)
        post_me = add_post('ccme', ccme, post_me)
        post_me = add_post('action', 'emailuser', post_me)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def undelete(title = nil, token = nil, reason = nil, timestamps = nil, post_me = nil)
    
        post_me = add_post('title', title, post_me)
        post_me = add_post('token', token, post_me)
        post_me = add_post('reason', reason, post_me)
        post_me = add_post('timestamps', timestamps, post_me)
        post_me = add_post('action', 'undelete', post_me)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def import(token = nil, summary = nil, xml = nil, interwikisource = nil, interwikipage = nil, fullhistory = nil, templates = nil, namespace = nil, post_me = nil)
    
        post_me = add_post('token', token, post_me)
        post_me = add_post('summary', summary, post_me)
        post_me = add_post('xml', xml, post_me)
        post_me = add_post('interwikisource', interwikisource, post_me)
        post_me = add_post('interwikipage', interwikipage, post_me)
        post_me = add_post('fullhistory', fullhistory, post_me)
        post_me = add_post('templates', templates, post_me)
        post_me = add_post('namespace', namespace, post_me)
        post_me = add_post('action', 'import', post_me)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end
    
    def unblock(id = nil, user = nil, token = nil, gettoken = nil, reason = nil, post_me = nil)
    
        post_me = add_post('id', id, post_me)
        post_me = add_post('user', user, post_me)
        post_me = add_post('token', token, post_me)
        post_me = add_post('gettoken', gettoken, post_me)
        post_me = add_post('reason', reason, post_me)
        post_me = add_post('action', 'unblock', post_me)
        post_me = format(post_me, 'xml')
        result = make_request(post_me)
        return result
    end

    # method for adding common parameters for all the methods of the type
    # query
    def query(post_me = nil, titles = nil, pageid = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil)
        post_me = add_post('titles', titles, post_me)
        post_me = add_post('pageid', pageid, post_me)
        post_me = add_post('revids', revids, post_me)
        post_me = add_post('redirects', redirects, post_me )
        post_me = add_post('indexpageids', indexpageids, post_me)
        post_me = add_post('export', export, post_me)
        post_me = add_post('exportnowrap', exportnowrap, post_me)
        post_me = add_post('action', 'query', post_me)
        return post_me
    end
   
    #method for defining the format. Currently overriden at make_request
    def format(post_me, format = nil)
        post_me = add_post('format', format, post_me)
        return post_me
    end

    #based on rwikibot by Eddie Roger, this method makes a post request to 
    #the api using the values specified at post_this and the cookies obtained
    #during the login (if available)
    #
    #Returns a xml with the result of the query
    def make_request(post_this)
        if !post_this.key?('format') or !post_this['format']
            post_this['format'] = 'xml'
        end

        if @config['logged']
            cookies= "#{@config['cookieprefix']}UserName=#{@config['lgusername']}; #{@config['cookieprefix']}UserID=#{@config['lguserid']}; #{@config['cookieprefix']}Token=#{@config['lgtoken']}; #{@config['cookieprefix']}_session=#{@config['_session']}"
        else
            cookies = ""
        end

        headers =  {
            'User-agent'=>Ourconfig['user-agent'], 
            'Cookie' => cookies
        }
        uri = URI.parse(@config['api_url']) 
        request = Net::HTTP::Post.new(uri.path, headers)
        request.set_form_data(post_this)
        response = Net::HTTP.new(uri.host, uri.port).start { |http| 
            http.request(request)
        }
        resputf8 = '<?xml version="1.0" encoding="UTF-8" ?>'+response.body[21..-1]

        return_result = XmlSimple.xml_in(resputf8, { 'ForceArray' => false })	
        return return_result
    end

    def add_post(key, value, post_me = nil)
        if !post_me
            post_me = Hash.new()
        end
        if value
            post_me[key]=value
        end
        return post_me
    end
end

#code from rwikibot
class Hash
  def to_s
    out = "{"
    self.each do |key, value|
      out += "#{key} => #{value},"
    end
    out = out.chop
    out += "}"
  end
end
