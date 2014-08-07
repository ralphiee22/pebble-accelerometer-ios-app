#include <pebble.h>

// use to see values printed every 4 seconds
#define ACCEL_STEP_MS 4000

#define timer_interval 100
static Window *window;
static TextLayer *text_layer;

static TextLayer *load_layer;
uint8_t num_samples = 10;
int i = 0;
char buffer[32];
char time_buf[15];
bool waiting_data = false;
bool msg_run = false;
char *xyz_str = "X,Y,Z:";
DictionaryIterator *iter;


void out_sent_handler(DictionaryIterator *sent, void *context) {
    // outgoing message was delivered
    //APP_LOG(APP_LOG_LEVEL_DEBUG, "DICTIONARY SENT SUCCESSFULLY!");
    msg_run = false;
}


void out_failed_handler(DictionaryIterator *failed, AppMessageResult reason, void *context) {
    // outgoing message failed
    //APP_LOG(APP_LOG_LEVEL_DEBUG, "DICTIONARY NOT SENT! ERROR!");
   //text_layer_set_text(load_layer, "ERROR!!!!");
    msg_run = false;

}

void accel_data_handler(AccelData *data, uint32_t num_samples) {
    // Process 10 events - every 1 second
    AccelData* d = data;
    
    // create dictionary object
    //DictionaryIterator *iter;
    app_message_outbox_begin(&iter);
    
    for (uint8_t i = 0; i < num_samples; i++, d++) {
        snprintf(xyz_str, 16, "%d,%d,%d", d->x, d->y, d->z);
       Tuplet xyzstr_val = TupletCString(i, xyz_str);
        dict_write_tuplet(iter, &xyzstr_val);
	}
    waiting_data = true;

    // send dictionary to phone
    app_message_outbox_send();
}

static void window_load(Window *window) {
  Layer *window_layer = window_get_root_layer(window);
  GRect bounds = layer_get_bounds(window_layer);

  //text_layer = text_layer_create((GRect) { .origin = { 0, 72 }, .size = { bounds.size.w, 20 } });
    load_layer = text_layer_create((GRect) { .origin = { 0, 72 }, .size = { bounds.size.w, 20 } });
    

  text_layer_set_text(load_layer, "Sending Data...");
  
   // text_layer_set_text_alignment(text_layer, GTextAlignmentCenter);
    text_layer_set_text_alignment(load_layer, GTextAlignmentCenter);
    text_layer_set_text_color(load_layer, GColorWhite);
    text_layer_set_background_color(load_layer, GColorBlack);
 
  //  layer_add_child(window_layer, text_layer_get_layer(text_layer));
    layer_add_child(window_layer, text_layer_get_layer(load_layer));
}

static void window_unload(Window *window) {
  text_layer_destroy(text_layer);
  text_layer_destroy(load_layer);
}

static void init(void) {
  window = window_create();
  window_set_window_handlers(window, (WindowHandlers) {
    .load = window_load,
    .unload = window_unload,
  });
  const bool animated = true;
  window_stack_push(window, animated);

    // subscribe to listen to acc data
 // accel_data_service_subscribe(0, NULL);
    accel_data_service_subscribe(25, &accel_data_handler);
    accel_service_set_sampling_rate(ACCEL_SAMPLING_25HZ);
    
    // set up outbox message handlers
 app_message_register_outbox_sent(out_sent_handler);
  app_message_register_outbox_failed(out_failed_handler);
    
    const uint32_t inbound_size = 64;
    const uint32_t outbound_size = 600;
    app_message_open(inbound_size, outbound_size);
    app_comm_set_sniff_interval(SNIFF_INTERVAL_REDUCED);
    //timer = app_timer_register(timer_interval, timer_callback, NULL);



 // timer = app_timer_register(1, timer_callback, NULL);
    //loadTimer = app_timer_register(0, load_callback1, NULL);
}

static void deinit(void) {
 accel_data_service_unsubscribe();
    app_comm_set_sniff_interval(SNIFF_INTERVAL_NORMAL);
  window_destroy(window);
}

int main(void) {
  init();

  APP_LOG(APP_LOG_LEVEL_DEBUG, "Done initializing, pushed window: %p", window);

  app_event_loop();
  deinit();
}
