(function(){
  const remembered=localStorage.getItem('safari_session');
  if(remembered&&!sessionStorage.getItem('safari_session')){
    let parsed;
    try{parsed=JSON.parse(remembered)}catch(e){localStorage.removeItem('safari_session');return}
    const expiresAt=Number(parsed.expires_at||0)*1000;
    const alreadyTried=sessionStorage.getItem('safari_restore_attempted')==='1';
    if(alreadyTried||(expiresAt&&expiresAt<Date.now()+60000)){
      localStorage.removeItem('safari_session');
      sessionStorage.removeItem('safari_session');
      sessionStorage.removeItem('safari_restore_attempted');
      return;
    }
    sessionStorage.setItem('safari_restore_attempted','1');
    sessionStorage.setItem('safari_session',remembered);
    if(!S.token){location.reload();return}
  }
  document.querySelector('#signOut').addEventListener('click',()=>{
    localStorage.removeItem('safari_session');
    sessionStorage.removeItem('safari_session');
    sessionStorage.removeItem('safari_restore_attempted');
  },true);
})();
