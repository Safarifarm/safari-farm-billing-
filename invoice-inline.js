(function(){
  const form=document.querySelector('#invoiceForm');
  const firstGrid=form.querySelector('.form-grid');
  const customerBlock=document.createElement('section');
  customerBlock.className='inline-customer';
  customerBlock.innerHTML=`
    <div class="section-title"><h3>Customer details</h3><span>Printed on invoice</span></div>
    <div class="customer-type-row"><label><input type="radio" name="inline_customer_type" value="GST"> GST Customer</label><label><input type="radio" name="inline_customer_type" value="NON-GST" checked> Non-GST Customer</label></div>
    <div class="form-grid three">
      <label>Customer name<input id="inlineName" required></label>
      <label>Mobile number<input id="inlinePhone"></label>
      <label>Email<input id="inlineEmail" type="email"></label>
      <label>GSTIN<input id="inlineGstin" placeholder="Required only for GST customer"></label>
      <label class="span2">Full address<input id="inlineAddress"></label>
      <label>State<input id="inlineState" value="West Bengal"></label>
      <label>District / City<input id="inlineDistrict" value="Malda"></label>
      <label>Pincode<input id="inlinePincode"></label>
    </div>`;
  firstGrid.insertAdjacentElement('beforebegin',customerBlock);
  const oldCustomer=document.querySelector('#invoiceCustomer');
  oldCustomer.required=false;
  oldCustomer.parentElement.hidden=true;

  function inlineCustomer(){return {
    id:oldCustomer.value||null,
    customer_type:document.querySelector('[name="inline_customer_type"]:checked').value,
    name:document.querySelector('#inlineName').value.trim(),
    phone:document.querySelector('#inlinePhone').value.trim(),
    email:document.querySelector('#inlineEmail').value.trim(),
    gstin:document.querySelector('#inlineGstin').value.trim(),
    address:document.querySelector('#inlineAddress').value.trim(),
    state:document.querySelector('#inlineState').value.trim(),
    district:document.querySelector('#inlineDistrict').value.trim(),
    pincode:document.querySelector('#inlinePincode').value.trim()
  }}

  const baseInvoiceData=invoiceData;
  invoiceData=function(){const d=baseInvoiceData();d.customer=inlineCustomer();return d};
  customerBlock.querySelectorAll('input').forEach(input=>input.addEventListener('input',renderPreview));

  form.onsubmit=async function(e){
    e.preventDefault();
    const c=inlineCustomer();
    if(!c.name)return toast('Customer name is required');
    if(c.customer_type==='GST'&&!c.gstin)return toast('GST customer ke liye GSTIN required hai');
    let customerId=c.id;
    try{
      if(!customerId){
        const payload={...c,owner_id:S.user.id,user_id:S.user.id};delete payload.id;
        const created=await api('customers',{method:'POST',body:payload});
        customerId=created?.[0]?.id;
        if(!customerId)throw Error('Customer could not be saved');
        S.customers.push({...c,id:customerId});
        oldCustomer.insertAdjacentHTML('beforeend',`<option value="${customerId}">${esc(c.name)}</option>`);
        oldCustomer.value=customerId;
      }
      await saveInvoice(e);
    }catch(error){toast(error.message)}
  };
  renderPreview();
})();
