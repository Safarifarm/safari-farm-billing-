// Separates authentication errors from database setup errors.
document.querySelector('#loginForm').onsubmit=async function(e){
  e.preventDefault();
  const message=document.querySelector('#loginMsg');
  const button=this.querySelector('button');
  button.disabled=true; button.textContent='Signing in…';
  let session;
  try {
    session=await login(document.querySelector('#email').value.trim(),document.querySelector('#password').value);
  } catch(error) {
    message.textContent=error.message;
    button.disabled=false; button.textContent='Sign in securely'; return;
  }
  S.token=session.access_token; S.user=session.user;
  localStorage.setItem('safari_session',JSON.stringify(session));
  sessionStorage.setItem('safari_session',JSON.stringify(session));
  sessionStorage.removeItem('safari_restore_attempted');
  message.textContent='Login successful. Loading farm data…';
  try {
    await load();
    document.querySelector('#login').hidden=true;
    document.querySelector('#app').hidden=false;
  } catch(error) {
    console.error(error);
    message.textContent='Login successful, but database setup is incomplete. Run the latest supabase-migration.sql. '+error.message;
    button.disabled=false; button.textContent='Sign in securely';
  }
};

// Add a complete customer directly from the invoice screen.
const customerSelect=document.querySelector('#invoiceCustomer');
const quickCustomerButton=document.createElement('button');
quickCustomerButton.type='button';
quickCustomerButton.id='quickAddCustomer';
quickCustomerButton.textContent='＋ New Customer';
customerSelect.insertAdjacentElement('afterend',quickCustomerButton);
customerSelect.parentElement.classList.add('invoice-customer-label');
quickCustomerButton.onclick=()=>editCustomer();
