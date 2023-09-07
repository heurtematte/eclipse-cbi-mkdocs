local util = import '../util.libsonnet';
local xtd = import 'github.com/jsonnet-libs/xtd/main.libsonnet';
{
  local config = $._config,
  
  _config+:: {
    local matrixDomain = util.getDomain(config.matrixDomain, config.environment),
    local chatDomain = util.getDomain(config.chatDomain, config.environment),
    
    elementweb+:{
      config+:{        
        'default_server_config'+: {
            'm.homeserver'+: {
                'base_url': 'https://'+ matrixDomain,
                'server_name': matrixDomain
            },
            'm.identity_server'+: {
                'base_url': 'https://vector.im'
            }
        },
        'disable_custom_urls': true,
        'disable_guests': false,
        'disable_login_language_selector': false,
        'disable_3pid_login': true,
        'brand': 'Eclipse Foundation Chat Community ',
        'permalink_prefix': 'https://' + chatDomain,
        'default_country_code': 'GB',
        'embeddedPages': {
            'homeUrl': 'https://' + chatDomain + '/home.html'
        },
        'show_labs_settings': false,
        'features'+: { 
            'feature_exploring_public_spaces': true,
            'feature_breadcrumbs_v2': true,
            'feature_html_topic': true,
            'feature_favourite_messages': true,
            'feature_roomlist_preview_reactions_all': true,
            'feature_presence_in_room_list': true,
            'feature_pinning': true,
            'feature_report_to_moderators': true,
            'feature_mjolnir': false
        },
        'default_federate': true,
        'default_theme': 'dark',
        'room_directory'+: {
            'servers'+: [
                'https://' + matrixDomain,
                'https://matrix.org'
            ]
        },
        'setting_defaults'+: {
            'enableSyntaxHighlightLanguageDetection': true,
            'feature_exploring_public_spaces': true,
            'feature_breadcrumbs_v2': true,
            'feature_html_topic': true,
            'feature_favourite_messages': true,
            'feature_roomlist_preview_reactions_all': true,
            'feature_presence_in_room_list': true,
            'feature_pinning': true,
            'feature_report_to_moderators': true,
            'feature_mjolnir': false,
            'UIFeature.registration': true,
            'UIFeature.urlPreviews': true,
            'UIFeature.shareQrCode': true,
            'UIFeature.shareSocial': true,
            'UIFeature.advancedSettings': true,
            'UIFeature.roomHistorySettings': true,
            'UIFeature.timelineEnableRelativeDates': true,
            'UIFeature.passwordReset': true,
            'UIFeature.thirdPartyId': true,
            'UIFeature.deactivate': true,
            'UIFeature.voip': false,
            'UIFeature.feedback': false
        },
        'map_style_url': 'https://api.maptiler.com/maps/streets/style.json?key=fU3vlMsMn4Jb6dnEIFsx',
        'branding'+: {
            'auth_header_logo_url': 'https://www.eclipse.org/eclipse.org-common/themes/solstice/public/images/logo/eclipse-foundation-grey-orange.svg',
            'welcome_background_url': 'https://' + chatDomain + '/banner.jpg',
            'auth_footer_links'+: []
                // {'text': 'Eclipse Projects', 'url': 'https://projects.eclipse.org/'},
                // {'text': 'Code of conduct', 'url': 'https://www.eclipse.org/org/documents/Community_Code_of_Conduct.php'},
                // {'text': 'Privacy Policy', 'url': 'https://www.eclipse.org/legal/privacy.php'},
                // {'text': 'Terms of use', 'url': 'http://www.eclipse.org/legal/termsofuse.php'},
                // {'text': 'Copyright Agent', 'url': 'https://www.eclipse.org/legal/copyright.php'},
                // {'text': 'Communication channel guidelines', 'url': 'https://www.eclipse.org/org/documents/communication-channel-guidelines/'},
                // {'text': 'Helpdesk', 'url': 'https://gitlab.eclipse.org/eclipsefdn/helpdesk'},
                // {'text': 'Chat Service status', 'url': 'https://www.eclipsestatus.io/'}            
        },
        "custom_translations_url": "https://"+ chatDomain + "/translation.json",
        'reportEvent'+: {
            'adminMessageMD': 'We wanted to remind you of our chat platform\'s Code of Conduct, which outlines the expectations for appropriate behavior on our platform. Before reporting, please ensure that you are familiar with these guidelines to avoid any confusion or misunderstandings. It is important to note that reporting another user\'s behavior should only be done in cases where their behavior violates our Code of Conduct. If you are unsure whether or not the behavior in question is a violation, please review the guidelines and/or reach out to an administrator for guidance.'
        },

        'terms_and_conditions_links'+: [
            {   
                'url': 'https://www.eclipse.org/org/documents/Community_Code_of_Conduct.php' ,
                'text': 'Code of conduct'
            },
            {   
                'url': 'http://www.eclipse.org/legal/termsofuse.php' ,
                'text': 'Terms of use'
            },
            {
                'url': 'http://www.eclipse.org/legal/privacy.php',
                'text': 'Privacy Policy'
            },
            {
                'url': 'https://www.eclipse.org/legal/copyright.php',
                'text': 'Copyright Agent'
            },
            {
                'url': 'https://www.eclipse.org/org/documents/communication-channel-guidelines/',
                'text': 'Communication channel guidelines'
            }
        ]
      }
    }
  }
}