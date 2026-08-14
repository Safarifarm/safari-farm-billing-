export const demoCustomers = [
 {id:'c1',name:'Green Valley Agro',customer_type:'GST',phone:'98765 43210',email:'accounts@greenvalley.in',gstin:'27ABCDE1234F1Z5',address:'Nashik, Maharashtra',state:'Maharashtra',state_code:'27'},
 {id:'c2',name:'Rahul Poultry Farm',customer_type:'Non-GST',phone:'99887 76655',email:'',gstin:'',address:'Indore, Madhya Pradesh',state:'Madhya Pradesh',state_code:'23'},
 {id:'c3',name:'Sunrise Feeds',customer_type:'GST',phone:'91234 56789',email:'hello@sunrisefeeds.in',gstin:'23AAECS1234G1ZX',address:'Bhopal, Madhya Pradesh',state:'Madhya Pradesh',state_code:'23'}]
export const demoProducts = [
 {id:'p1',name:'Kadaknath Chicks',sku:'SFC-KC-01',hsn:'0105',unit:'Nos',purchase_price:65,sale_price:85,extra_price:95,gst_rate:5,current_stock:1280,low_stock_threshold:300,image_url:''},
 {id:'p2',name:'Country Eggs',sku:'SFC-EGG-01',hsn:'0407',unit:'Tray',purchase_price:175,sale_price:210,extra_price:225,gst_rate:5,current_stock:84,low_stock_threshold:100,image_url:''},
 {id:'p3',name:'Poultry Feed - Starter',sku:'SFC-FD-01',hsn:'2309',unit:'Bag',purchase_price:1250,sale_price:1450,extra_price:1550,gst_rate:5,current_stock:46,low_stock_threshold:20,image_url:''},
 {id:'p4',name:'Vaccinated Grower Birds',sku:'SFC-GB-01',hsn:'0105',unit:'Nos',purchase_price:380,sale_price:475,extra_price:525,gst_rate:5,current_stock:210,low_stock_threshold:50,image_url:''}]
export const demoInvoices = [
 {id:'i1',invoice_no:'SFH-2026-0042',process_no:'PR-2026-0042',inquiry_no:'INQ-2026-0068',invoice_date:'2026-08-13',customer:demoCustomers[0],subtotal:42000,tax_total:2100,grand_total:44100,amount_paid:44100,payment_status:'Paid',items:[]},
 {id:'i2',invoice_no:'SFH-2026-0041',process_no:'PR-2026-0041',inquiry_no:'INQ-2026-0067',invoice_date:'2026-08-12',customer:demoCustomers[1],subtotal:12750,tax_total:0,grand_total:12750,amount_paid:5000,payment_status:'Partial',items:[]},
 {id:'i3',invoice_no:'SFH-2026-0040',process_no:'PR-2026-0040',inquiry_no:'INQ-2026-0066',invoice_date:'2026-08-10',customer:demoCustomers[2],subtotal:29000,tax_total:1450,grand_total:30450,amount_paid:0,payment_status:'Unpaid',items:[]}]
export const defaultSettings = {business_name:'SAFARI FARM & HATCHERY',tagline:'Quality Chicks • Healthy Flocks • Trusted Service',address:'Village Road, District, Madhya Pradesh - 000000',phone:'+91 98765 43210',email:'billing@safarifarm.in',gstin:'23ABCDE1234F1Z5',bank_name:'State Bank of India',account_name:'Safari Farm & Hatchery',account_no:'000000000000',ifsc:'SBIN0000000',branch:'Main Branch',upi_id:'safarifarm@upi',notes:'Goods once sold will not be taken back. Subject to local jurisdiction.',terms:'Payment due within 7 days.',logo_url:'/safari-logo.png',signature_url:''}
