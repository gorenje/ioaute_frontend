/*
 * Created by Gerrit Riessen
 * Copyright 2010-2011, Gerrit Riessen
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
  This is always imported after the frameworks have all been imported. So things that
  monkey patch framework classes can also be imported here.
*/

// monkey patches, a lot of files with no content but it all comes out in the wash,
// i.e. after flatten, everything is in one large file. And this way, i have an overview
// of what has been monkey patched.
@import "monkeypatch/c_p_alert.j"
@import "monkeypatch/c_p_array.j"
@import "monkeypatch/c_p_box.j"
@import "monkeypatch/c_p_cib.j"
@import "monkeypatch/c_p_collection_view.j"
@import "monkeypatch/c_p_color.j"
@import "monkeypatch/c_p_cursor.j"
@import "monkeypatch/c_p_date.j"
@import "monkeypatch/c_p_event.j"
@import "monkeypatch/c_p_menu_item.j"
@import "monkeypatch/c_p_string.j"
@import "monkeypatch/c_p_text_field.j"
@import "monkeypatch/l_p_multi_line_text_field.j"
// helpers
@import "helpers/application_helpers.j"
@import "helpers/image_loader_helpers.j"
@import "helpers/alert_user_helper.j"
// library
@import "libs/drag_drop_manager.j"
@import "libs/placeholder_manager.j"
@import "libs/configuration_manager.j"
@import "libs/communication_workers.j"
@import "libs/communication_manager.j"
@import "libs/theme_manager.j"
// mixins
@import "mixins/seek_to_dropdown_helpers.j"
@import "mixins/document_view_cell_snapgrid.j"
@import "mixins/you_tube_video_properties.j"
@import "mixins/you_tube_page_element.j"
@import "mixins/image_element_properties.j"
@import "mixins/alert_window_support.j"
@import "mixins/object_state_support.j"
// mixins for page elements
@import "mixins/page_element/color_support.j"
@import "mixins/page_element/size_support.j"
@import "mixins/page_element/input_support.j"
@import "mixins/page_element/font_support.j"
@import "mixins/page_element/text_input_support.j"
@import "mixins/page_element/rotation_support.j"
// mixins for property controllers
@import "mixins/property_controller/font_support.j"
@import "mixins/property_controller/rotation_support.j"
@import "mixins/property_controller/image_support.j"
@import "mixins/property_controller/image_flag_support.j"
// models
@import "models/page.j"
@import "models/page_element.j"
@import "models/tweet.j"
@import "models/flickr.j"
@import "models/facebook.j"
@import "models/google_image.j"
@import "models/tool_element.j"
@import "models/image_t_e.j"
@import "models/text_t_e.j"
@import "models/fb_like_t_e.j"
@import "models/twitter_feed_t_e.j"
@import "models/tweet_t_e.j"
@import "models/digg_button_t_e.j"
@import "models/link_t_e.j"
@import "models/highlight_t_e.j"
@import "models/you_tube_video.j"
@import "models/you_tube_ctrl_t_e.j"
@import "models/you_tube_t_e.j"
@import "models/pay_pal_button_t_e.j"
@import "models/you_tube_seek_to_link_t_e.j"
@import "models/pub_config.j"
// views
@import "views/document_view.j"
@import "views/document_view_cell.j"
@import "views/document_view_editor_view.j"
@import "views/base_image_cell.j"
@import "views/flickr_photo_cell.j"
@import "views/facebook_photo_cell.j"
@import "views/google_images_photo_cell.j"
@import "views/you_tube_photo_cell.j"
@import "views/facebook_category_cell.j"
@import "views/page_number_list_cell.j"
@import "views/page_number_view.j"
@import "views/page_control_cell.j"
@import "views/tool_list_cell.j"
@import "views/tweet_data_view.j"
// views for specific models
@import "views/models/p_m_highlight_view.j"
@import "views/models/p_m_image_view.j"
// controllers
@import "controllers/prompt_window_controller.j"
@import "controllers/twitter_controller.j"
@import "controllers/flickr_controller.j"
@import "controllers/you_tube_controller.j"
@import "controllers/facebook_controller.j"
@import "controllers/google_images_controller.j"
@import "controllers/tool_view_controller.j"
@import "controllers/page_view_controller.j"
@import "controllers/document_view_controller.j"
@import "controllers/document_view_controller_edit_existing.j"
// controllers - property windows
@import "controllers/properties/property_window_controller.j"
@import "controllers/properties/property_publication_controller.j"
@import "controllers/properties/property_link_t_e_controller.j"
@import "controllers/properties/property_highlight_t_e_controller.j"
@import "controllers/properties/property_image_t_e_controller.j"
@import "controllers/properties/property_facebook_image_controller.j"
@import "controllers/properties/property_flickr_image_controller.j"
@import "controllers/properties/property_twitter_feed_t_e_controller.j"
@import "controllers/properties/property_text_t_e_controller.j"
@import "controllers/properties/property_text_t_e_controller.j"
@import "controllers/properties/property_page_controller.j"
@import "controllers/properties/property_you_tube_video_controller.j"
@import "controllers/properties/property_pay_pal_button_controller.j"
@import "controllers/properties/property_you_tube_seek_to_link_t_e_controller.j"
