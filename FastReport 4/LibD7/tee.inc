//------------------- TeeChart component ----------------------------
{$DEFINE TeeChartStd}

//------------------- TeeChart Pro 4 component --------------------
// If you have TeeChart Pro 4, uncomment the following line:
//{$DEFINE TeeChart4}

//------------------- TeeChart Pro 5 component --------------------
// If you have TeeChart Pro 5, uncomment the following line:
//{$DEFINE TeeChart5}

//------------------- TeeChart Pro 6 component ----------------------
// If you have TeeChart Pro 6, uncomment the following line:
//{$DEFINE TeeChart6}

//------------------- TeeChart Pro 7 component ----------------------
// If you have TeeChart Pro 7, uncomment the following line:
//{$DEFINE TeeChart7}


// Don't change here ------------------------------------------------
{$IFDEF TeeChart4}
  {$UNDEF TeeChartStd}
  {$DEFINE TeeChartPro}
{$ENDIF}

{$IFDEF TeeChart5}
  {$UNDEF TeeChartStd}
  {$DEFINE TeeChartPro}
{$ENDIF}

{$IFDEF TeeChart6}
  {$UNDEF TeeChartStd}
  {$DEFINE TeeChartPro}
{$ENDIF}

{$IFDEF TeeChart7}
  {$UNDEF TeeChartStd}
  {$DEFINE TeeChartPro}
{$ENDIF}
