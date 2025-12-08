import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'dashboard',
      component: () => import('@/views/Dashboard.vue')
    },
    {
      path: '/estacionamiento-publico',
      name: 'estacionamiento-publico',
      component: () => import('@/views/modules/estacionamiento_publico/index.vue')
    },
    { path: '/estacionamiento-publico/consulta', name: 'estacionamiento-publico-consulta', component: () => import('@/views/modules/estacionamiento_publico/ConsultaPublicos.vue') },
    { path: '/estacionamiento-publico/transacciones', name: 'estacionamiento-publico-transacciones', component: () => import('@/views/modules/estacionamiento_publico/TransPublicos.vue') },
    { path: '/estacionamiento-publico/actualizacion', name: 'estacionamiento-publico-actualizacion', component: () => import('@/views/modules/estacionamiento_publico/ActualizacionPublicos.vue') },
    { path: '/estacionamiento-publico/nuevo', name: 'estacionamiento-publico-nuevo', component: () => import('@/views/modules/estacionamiento_publico/PublicosNew.vue') },
    { path: '/estacionamiento-publico/reportes', name: 'estacionamiento-publico-reportes', component: () => import('@/views/modules/estacionamiento_publico/ReportesPublicos.vue') },
    { path: '/estacionamiento-publico/accesos', name: 'estacionamiento-publico-accesos', component: () => import('@/views/modules/estacionamiento_publico/AccesoPublicos.vue') },
    { path: '/estacionamiento-publico/admin', name: 'estacionamiento-publico-admin', component: () => import('@/views/modules/estacionamiento_publico/AdminPublicos.vue') },
    { path: '/estacionamiento-publico/bajas', name: 'estacionamiento-publico-bajas', component: () => import('@/views/modules/estacionamiento_publico/BajasPublicos.vue') },
    { path: '/estacionamiento-publico/generar', name: 'estacionamiento-publico-generar', component: () => import('@/views/modules/estacionamiento_publico/GenerarPublicos.vue') },
    { path: '/estacionamiento-publico/pagos', name: 'estacionamiento-publico-pagos', component: () => import('@/views/modules/estacionamiento_publico/PagosPublicos.vue') },
    { path: '/estacionamiento-publico/info', name: 'estacionamiento-publico-info', component: () => import('@/views/modules/estacionamiento_publico/InfoPublicos.vue') },
    { path: '/estacionamiento-publico/listados', name: 'estacionamiento-publico-listados', component: () => import('@/views/modules/estacionamiento_publico/ListadosPublicos.vue') },
    { path: '/estacionamiento-publico/estadisticas', name: 'estacionamiento-publico-estadisticas', component: () => import('@/views/modules/estacionamiento_publico/EstadisticasPublicos.vue') },
    { path: '/estacionamiento-publico/conciliacion', name: 'estacionamiento-publico-conciliacion', component: () => import('@/views/modules/estacionamiento_publico/ConciBanortePublicos.vue') },
    { path: '/estacionamiento-publico/edocta', name: 'estacionamiento-publico-edocta', component: () => import('@/views/modules/estacionamiento_publico/EdoCtaPublicos.vue') },
    { path: '/estacionamiento-publico/reporte-lista', name: 'estacionamiento-publico-reporte-lista', component: () => import('@/views/modules/estacionamiento_publico/ReporteListaPublicos.vue') },
    { path: '/estacionamiento-publico/reporte-pagos', name: 'estacionamiento-publico-reporte-pagos', component: () => import('@/views/modules/estacionamiento_publico/ReportePagosPublicos.vue') },
    { path: '/estacionamiento-publico/reporte-folios', name: 'estacionamiento-publico-reporte-folios', component: () => import('@/views/modules/estacionamiento_publico/ReporteFoliosPublicos.vue') },
    { path: '/estacionamiento-publico/estado-mpio', name: 'estacionamiento-publico-estado-mpio', component: () => import('@/views/modules/estacionamiento_publico/EstadoMpioPublicos.vue') },
    { path: '/estacionamiento-publico/trans-folios', name: 'estacionamiento-publico-trans-folios', component: () => import('@/views/modules/estacionamiento_publico/TransFoliosPublicos.vue') },
    { path: '/estacionamiento-publico/up-pagos', name: 'estacionamiento-publico-up-pagos', component: () => import('@/views/modules/estacionamiento_publico/UpPagosPublicos.vue') },
    { path: '/estacionamiento-publico/valet-paso', name: 'estacionamiento-publico-valet-paso', component: () => import('@/views/modules/estacionamiento_publico/ValetPasoPublicos.vue') },
    { path: '/estacionamiento-publico/passwords', name: 'estacionamiento-publico-passwords', component: () => import('@/views/modules/estacionamiento_publico/PasswordsPublicos.vue') },
    { path: '/estacionamiento-publico/gen-arc-altas', name: 'estacionamiento-publico-gen-arc-altas', component: () => import('@/views/modules/estacionamiento_publico/GenArcAltasPublicos.vue') },
    { path: '/estacionamiento-publico/gen-arc-diario', name: 'estacionamiento-publico-gen-arc-diario', component: () => import('@/views/modules/estacionamiento_publico/GenArcDiarioPublicos.vue') },
    { path: '/estacionamiento-publico/gen-individual', name: 'estacionamiento-publico-gen-individual', component: () => import('@/views/modules/estacionamiento_publico/GenIndividualPublicos.vue') },
    { path: '/estacionamiento-publico/gen-pgos-banorte', name: 'estacionamiento-publico-gen-pgos-banorte', component: () => import('@/views/modules/estacionamiento_publico/GenPgosBanortePublicos.vue') },
    { path: '/estacionamiento-publico/reactiva-folios', name: 'estacionamiento-publico-reactiva-folios', component: () => import('@/views/modules/estacionamiento_publico/ReactivaFoliosPublicos.vue') },
    { path: '/estacionamiento-publico/cons-gral', name: 'estacionamiento-publico-cons-gral', component: () => import('@/views/modules/estacionamiento_publico/ConsGralPublicos.vue') },
    { path: '/estacionamiento-publico/cons-remesas', name: 'estacionamiento-publico-cons-remesas', component: () => import('@/views/modules/estacionamiento_publico/ConsRemesasPublicos.vue') },
    { path: '/estacionamiento-publico/aplica-pago-divadmin', name: 'estacionamiento-publico-aplica-pago-divadmin', component: () => import('@/views/modules/estacionamiento_publico/AplicaPagoDivAdminPublicos.vue') },
    { path: '/estacionamiento-publico/relacion-folios', name: 'estacionamiento-publico-relacion-folios', component: () => import('@/views/modules/estacionamiento_publico/RelacionFoliosPublicos.vue') },
    { path: '/estacionamiento-publico/imp-padron', name: 'estacionamiento-publico-imp-padron', component: () => import('@/views/modules/estacionamiento_publico/ImpPadronPublicos.vue') },
    { path: '/estacionamiento-publico/metrometers', name: 'estacionamiento-publico-metrometers', component: () => import('@/views/modules/estacionamiento_publico/MetrometersPublicos.vue') },
    { path: '/estacionamiento-publico/aspecto', name: 'estacionamiento-publico-aspecto', component: () => import('@/views/modules/estacionamiento_publico/AspectoPublicos.vue') },
    { path: '/estacionamiento-publico/autoriz-descto', name: 'estacionamiento-publico-autoriz-descto', component: () => import('@/views/modules/estacionamiento_publico/ChgAutorizDesctoPublicos.vue') },
    { path: '/estacionamiento-publico/contrarecibos', name: 'estacionamiento-publico-contrarecibos', component: () => import('@/views/modules/estacionamiento_publico/ContrarecibosPublicos.vue') },
    { path: '/estacionamiento-publico/mensaje', name: 'estacionamiento-publico-mensaje', component: () => import('@/views/modules/estacionamiento_publico/MensajePublicos.vue') },
    { path: '/estacionamiento-publico/folios-alta', name: 'estacionamiento-publico-folios-alta', component: () => import('@/views/modules/estacionamiento_publico/FoliosAltaPublicos.vue') },
    { path: '/estacionamiento-publico/carga-edoex', name: 'estacionamiento-publico-carga-edoex', component: () => import('@/views/modules/estacionamiento_publico/CargaEdoExPublicos.vue') },
    { path: '/estacionamiento-publico/predio-carto', name: 'estacionamiento-publico-predio-carto', component: () => import('@/views/modules/estacionamiento_publico/PredioCartoPublicos.vue') },
    { path: '/estacionamiento-publico/reportes-calco', name: 'estacionamiento-publico-reportes-calco', component: () => import('@/views/modules/estacionamiento_publico/ReportesCalcoPublicos.vue') },
    { path: '/estacionamiento-publico/solic-rep-folios', name: 'estacionamiento-publico-solic-rep-folios', component: () => import('@/views/modules/estacionamiento_publico/SolicRepFoliosPublicos.vue') },
    { path: '/estacionamiento-publico/seguridad-login', name: 'estacionamiento-publico-seguridad-login', component: () => import('@/views/modules/estacionamiento_publico/SeguridadLoginPublicos.vue') },
    { path: '/estacionamiento-publico/inspectores', name: 'estacionamiento-publico-inspectores', component: () => import('@/views/modules/estacionamiento_publico/InspectoresPublicos.vue') },
    { path: '/estacionamiento-publico/baja-multiple', name: 'estacionamiento-publico-baja-multiple', component: () => import('@/views/modules/estacionamiento_publico/BajaMultiplePublicos.vue') },
    { path: '/multas-reglamentos/captura-dif', name: 'multas-reglamentos-captura-dif', component: () => import('@/views/modules/multas_reglamentos/CapturaDif.vue') },
    { path: '/multas-reglamentos/carta-invitacion', name: 'multas-reglamentos-carta-invitacion', component: () => import('@/views/modules/multas_reglamentos/CartaInvitacion.vue') },
    { path: '/multas-reglamentos/drecgo-fosa', name: 'multas-reglamentos-drecgo-fosa', component: () => import('@/views/modules/multas_reglamentos/DrecgoFosa.vue') },
    { path: '/multas-reglamentos/drecgo-trans', name: 'multas-reglamentos-drecgo-trans', component: () => import('@/views/modules/multas_reglamentos/DrecgoTrans.vue') },
    { path: '/multas-reglamentos/ejecutores', name: 'multas-reglamentos-ejecutores', component: () => import('@/views/modules/multas_reglamentos/Ejecutores.vue') },
    { path: '/multas-reglamentos/exclusivos-upd', name: 'multas-reglamentos-exclusivos-upd', component: () => import('@/views/modules/multas_reglamentos/Exclusivos_Upd.vue') },
    { path: '/multas-reglamentos/extractos-rpt', name: 'multas-reglamentos-extractos-rpt', component: () => import('@/views/modules/multas_reglamentos/ExtractosRpt.vue') },
    { path: '/multas-reglamentos/firma-electronica', name: 'multas-reglamentos-firma-electronica', component: () => import('@/views/modules/multas_reglamentos/FirmaElectronica.vue') },
    { path: '/multas-reglamentos/fol-multa', name: 'multas-reglamentos-fol-multa', component: () => import('@/views/modules/multas_reglamentos/FolMulta.vue') },
    {
      path: '/aseo-contratado',
      name: 'aseo-contratado',
      component: () => import('@/views/modules/aseo_contratado/index.vue')
    },
    {
      path: '/aseo-contratado/empresas',
      name: 'aseo-contratado-empresas',
      component: () => import('@/views/modules/aseo_contratado/ABC_Empresas.vue')
    },
    {
      path: '/aseo-contratado/tipos-aseo',
      name: 'aseo-contratado-tipos-aseo',
      component: () => import('@/views/modules/aseo_contratado/ABC_Tipos_Aseo.vue')
    },
    {
      path: '/aseo-contratado/zonas',
      name: 'aseo-contratado-zonas',
      component: () => import('@/views/modules/aseo_contratado/ABC_Zonas.vue')
    },
    {
      path: '/aseo-contratado/unidades-recoleccion',
      name: 'aseo-contratado-unidades-recoleccion',
      component: () => import('@/views/modules/aseo_contratado/ABC_Und_Recolec.vue')
    },
    {
      path: '/aseo-contratado/recaudadoras',
      name: 'aseo-contratado-recaudadoras',
      component: () => import('@/views/modules/aseo_contratado/ABC_Recaudadoras.vue')
    },
    {
      path: '/aseo-contratado/claves-operacion',
      name: 'aseo-contratado-claves-operacion',
      component: () => import('@/views/modules/aseo_contratado/ABC_Cves_Operacion.vue')
    },
    {
      path: '/aseo-contratado/gastos',
      name: 'aseo-contratado-gastos',
      component: () => import('@/views/modules/aseo_contratado/ABC_Gastos.vue')
    },
    {
      path: '/aseo-contratado/recargos',
      name: 'aseo-contratado-recargos',
      component: () => import('@/views/modules/aseo_contratado/ABC_Recargos.vue')
    },
    {
      path: '/aseo-contratado/tipos-empresa',
      name: 'aseo-contratado-tipos-empresa',
      component: () => import('@/views/modules/aseo_contratado/ABC_Tipos_Emp.vue')
    },
    {
      path: '/aseo-contratado/adeudos',
      name: 'aseo-contratado-adeudos',
      component: () => import('@/views/modules/aseo_contratado/Adeudos.vue')
    },
    {
      path: '/aseo-contratado/adeudos-carga',
      name: 'aseo-contratado-adeudos-carga',
      component: () => import('@/views/modules/aseo_contratado/Adeudos_Carga.vue')
    },
    {
      path: '/aseo-contratado/adeudos-nvo',
      name: 'aseo-contratado-adeudos-nvo',
      component: () => import('@/views/modules/aseo_contratado/Adeudos_Nvo.vue')
    },
    {
      path: '/aseo-contratado/adeudos-ins',
      name: 'aseo-contratado-adeudos-ins',
      component: () => import('@/views/modules/aseo_contratado/Adeudos_Ins.vue')
    },
    {
      path: '/aseo-contratado/adeudos-pag',
      name: 'aseo-contratado-adeudos-pag',
      component: () => import('@/views/modules/aseo_contratado/Adeudos_Pag.vue')
    },
    {
      path: '/aseo-contratado/adeudos-edocta',
      name: 'aseo-contratado-adeudos-edocta',
      component: () => import('@/views/modules/aseo_contratado/Adeudos_EdoCta.vue')
    },
    {
      path: '/aseo-contratado/contratos-consulta',
      name: 'aseo-contratado-contratos-consulta',
      component: () => import('@/views/modules/aseo_contratado/Contratos_Consulta.vue')
    },
    {
      path: '/aseo-contratado/contratos-alta',
      name: 'aseo-contratado-contratos-alta',
      component: () => import('@/views/modules/aseo_contratado/Contratos_Alta.vue')
    },
    {
      path: '/aseo-contratado/contratos-mod',
      name: 'aseo-contratado-contratos-mod',
      component: () => import('@/views/modules/aseo_contratado/Contratos_Mod.vue')
    },
    {
      path: '/aseo-contratado/contratos-baja',
      name: 'aseo-contratado-contratos-baja',
      component: () => import('@/views/modules/aseo_contratado/Contratos_Baja.vue')
    },
    {
      path: '/aseo-contratado/actcont-cr',
      name: 'aseo-contratado-actcont-cr',
      component: () => import('@/views/modules/aseo_contratado/ActCont_CR.vue')
    },
    {
      path: '/aseo-contratado/rpt-adeudos',
      name: 'aseo-contratado-rpt-adeudos',
      component: () => import('@/views/modules/aseo_contratado/Rpt_Adeudos.vue')
    },
    {
      path: '/aseo-contratado/rpt-pagos',
      name: 'aseo-contratado-rpt-pagos',
      component: () => import('@/views/modules/aseo_contratado/Rpt_Pagos.vue')
    },
    {
      path: '/aseo-contratado/rpt-estado-cuenta',
      name: 'aseo-contratado-rpt-estado-cuenta',
      component: () => import('@/views/modules/aseo_contratado/Rpt_EstadoCuenta.vue')
    },
    {
      path: '/aseo-contratado/rpt-contratos',
      name: 'aseo-contratado-rpt-contratos',
      component: () => import('@/views/modules/aseo_contratado/Rpt_Contratos.vue')
    },
    {
      path: '/aseo-contratado/rpt-empresas',
      name: 'aseo-contratado-rpt-empresas',
      component: () => import('@/views/modules/aseo_contratado/Rpt_Empresas.vue')
    },
    {
      path: '/aseo-contratado/adeudos-est',
      name: 'aseo-contratado-adeudos-est',
      component: () => import('@/views/modules/aseo_contratado/AdeudosEst.vue')
    },
    {
      path: '/aseo-contratado/adeudos-mult-ins',
      name: 'aseo-contratado-adeudos-mult-ins',
      component: () => import('@/views/modules/aseo_contratado/AdeudosMult_Ins.vue')
    },
    {
      path: '/aseo-contratado/adeudos-exe-del',
      name: 'aseo-contratado-adeudos-exe-del',
      component: () => import('@/views/modules/aseo_contratado/AdeudosExe_Del.vue')
    },
    {
      path: '/aseo-contratado/adeudos-cn-cond',
      name: 'aseo-contratado-adeudos-cn-cond',
      component: () => import('@/views/modules/aseo_contratado/AdeudosCN_Cond.vue')
    },
    {
      path: '/aseo-contratado/adeudos-opc-mult',
      name: 'aseo-contratado-adeudos-opc-mult',
      component: () => import('@/views/modules/aseo_contratado/Adeudos_OpcMult.vue')
    },
    // LOTE 7: Operaciones Especiales y Convenios
    {
      path: '/aseo-contratado/aplica-multas',
      name: 'aseo-contratado-aplica-multas',
      component: () => import('@/views/modules/aseo_contratado/AplicaMultas.vue')
    },
    {
      path: '/aseo-contratado/datos-convenio',
      name: 'aseo-contratado-datos-convenio',
      component: () => import('@/views/modules/aseo_contratado/DatosConvenio.vue')
    },
    {
      path: '/aseo-contratado/descuentos-pago',
      name: 'aseo-contratado-descuentos-pago',
      component: () => import('@/views/modules/aseo_contratado/DescuentosPago.vue')
    },
    {
      path: '/aseo-contratado/ejercicios-gestion',
      name: 'aseo-contratado-ejercicios-gestion',
      component: () => import('@/views/modules/aseo_contratado/EjerciciosGestion.vue')
    },
    {
      path: '/aseo-contratado/relacion-contratos',
      name: 'aseo-contratado-relacion-contratos',
      component: () => import('@/views/modules/aseo_contratado/RelacionContratos.vue')
    },
    // LOTE 8: Pagos y Consultas Avanzadas
    {
      path: '/aseo-contratado/adeudos-pag-mult',
      name: 'aseo-contratado-adeudos-pag-mult',
      component: () => import('@/views/modules/aseo_contratado/Adeudos_PagMult.vue')
    },
    {
      path: '/aseo-contratado/adeudos-venc',
      name: 'aseo-contratado-adeudos-venc',
      component: () => import('@/views/modules/aseo_contratado/Adeudos_Venc.vue')
    },
    {
      path: '/aseo-contratado/contratos-adeudos',
      name: 'aseo-contratado-contratos-adeudos',
      component: () => import('@/views/modules/aseo_contratado/Contratos_Adeudos.vue')
    },
    {
      path: '/aseo-contratado/pagos-cons-cont',
      name: 'aseo-contratado-pagos-cons-cont',
      component: () => import('@/views/modules/aseo_contratado/Pagos_Cons_Cont.vue')
    },
    {
      path: '/aseo-contratado/empresas-contratos',
      name: 'aseo-contratado-empresas-contratos',
      component: () => import('@/views/modules/aseo_contratado/Empresas_Contratos.vue')
    },
    // LOTE 9: Adeudos y Pagos Adicionales
    {
      path: '/aseo-contratado/adeudos-pag-upd-per',
      name: 'aseo-contratado-adeudos-pag-upd-per',
      component: () => import('@/views/modules/aseo_contratado/Adeudos_PagUpdPer.vue')
    },
    {
      path: '/aseo-contratado/adeudos-upd-exed',
      name: 'aseo-contratado-adeudos-upd-exed',
      component: () => import('@/views/modules/aseo_contratado/Adeudos_UpdExed.vue')
    },
    {
      path: '/aseo-contratado/pagos-con-fpgo',
      name: 'aseo-contratado-pagos-con-fpgo',
      component: () => import('@/views/modules/aseo_contratado/Pagos_Con_FPgo.vue')
    },
    {
      path: '/aseo-contratado/pagos-cons-cont-asc',
      name: 'aseo-contratado-pagos-cons-cont-asc',
      component: () => import('@/views/modules/aseo_contratado/Pagos_Cons_ContAsc.vue')
    },
    {
      path: '/aseo-contratado/contratos-cancela',
      name: 'aseo-contratado-contratos-cancela',
      component: () => import('@/views/modules/aseo_contratado/Contratos_Cancela.vue')
    },
    // LOTE 10: Consultas y Reportes Adicionales
    {
      path: '/aseo-contratado/contratos-cons-admin',
      name: 'aseo-contratado-contratos-cons-admin',
      component: () => import('@/views/modules/aseo_contratado/Contratos_Cons_Admin.vue')
    },
    {
      path: '/aseo-contratado/contratos-cons-dom',
      name: 'aseo-contratado-contratos-cons-dom',
      component: () => import('@/views/modules/aseo_contratado/Contratos_Cons_Dom.vue')
    },
    {
      path: '/aseo-contratado/rep-padron-contratos',
      name: 'aseo-contratado-rep-padron-contratos',
      component: () => import('@/views/modules/aseo_contratado/Rep_PadronContratos.vue')
    },
    {
      path: '/aseo-contratado/rep-recaudadoras',
      name: 'aseo-contratado-rep-recaudadoras',
      component: () => import('@/views/modules/aseo_contratado/Rep_Recaudadoras.vue')
    },
    {
      path: '/aseo-contratado/rep-tipos-aseo',
      name: 'aseo-contratado-rep-tipos-aseo',
      component: () => import('@/views/modules/aseo_contratado/Rep_Tipos_Aseo.vue')
    },
    // LOTE 11: Actualizaciones y Estadísticas
    {
      path: '/aseo-contratado/contratos-upd-periodo',
      name: 'aseo-contratado-contratos-upd-periodo',
      component: () => import('@/views/modules/aseo_contratado/Contratos_Upd_Periodo.vue')
    },
    {
      path: '/aseo-contratado/contratos-upd-und',
      name: 'aseo-contratado-contratos-upd-und',
      component: () => import('@/views/modules/aseo_contratado/Contratos_Upd_Und.vue')
    },
    {
      path: '/aseo-contratado/contratos-est',
      name: 'aseo-contratado-contratos-est',
      component: () => import('@/views/modules/aseo_contratado/ContratosEst.vue')
    },
    {
      path: '/aseo-contratado/contratos-estgral',
      name: 'aseo-contratado-contratos-estgral',
      component: () => import('@/views/modules/aseo_contratado/Contratos_EstGral.vue')
    },
    {
      path: '/aseo-contratado/rep-adeud-cond',
      name: 'aseo-contratado-rep-adeud-cond',
      component: () => import('@/views/modules/aseo_contratado/Rep_AdeudCond.vue')
    },
    // LOTE 12: Consultas y Actualizaciones Adicionales
    {
      path: '/aseo-contratado/cons-cont',
      name: 'aseo-contratado-cons-cont',
      component: () => import('@/views/modules/aseo_contratado/Cons_Cont.vue')
    },
    {
      path: '/aseo-contratado/cons-cont-asc',
      name: 'aseo-contratado-cons-cont-asc',
      component: () => import('@/views/modules/aseo_contratado/Cons_ContAsc.vue')
    },
    {
      path: '/aseo-contratado/upd-01',
      name: 'aseo-contratado-upd-01',
      component: () => import('@/views/modules/aseo_contratado/Upd_01.vue')
    },
    {
      path: '/aseo-contratado/upd-ini-obl',
      name: 'aseo-contratado-upd-ini-obl',
      component: () => import('@/views/modules/aseo_contratado/Upd_IniObl.vue')
    },
    {
      path: '/aseo-contratado/rep-zonas',
      name: 'aseo-contratado-rep-zonas',
      component: () => import('@/views/modules/aseo_contratado/Rep_Zonas.vue')
    },
    // LOTE 13 FINAL: Componentes Finales del Módulo
    {
      path: '/aseo-contratado/upd-undc',
      name: 'aseo-contratado-upd-undc',
      component: () => import('@/views/modules/aseo_contratado/Upd_UndC.vue')
    },
    {
      path: '/aseo-contratado/updxcont',
      name: 'aseo-contratado-updxcont',
      component: () => import('@/views/modules/aseo_contratado/UpdxCont.vue')
    },
    {
      path: '/aseo-contratado/ins-b',
      name: 'aseo-contratado-ins-b',
      component: () => import('@/views/modules/aseo_contratado/Ins_b.vue')
    },
    {
      path: '/aseo-contratado/estgral2',
      name: 'aseo-contratado-estgral2',
      component: () => import('@/views/modules/aseo_contratado/EstGral2.vue')
    },
    {
      path: '/aseo-contratado/ctrol-imp-cat',
      name: 'aseo-contratado-ctrol-imp-cat',
      component: () => import('@/views/modules/aseo_contratado/Ctrol_Imp_Cat.vue')
    },
    {
      path: '/aseo-contratado/contratos',
      name: 'aseo-contratado-contratos',
      component: () => import('@/views/modules/aseo_contratado/Contratos.vue')
    },
    // CEMENTERIOS - Módulo de gestión de cementerios
    {
      path: '/cementerios',
      name: 'cementerios',
      component: () => import('@/views/modules/cementerios/index.vue')
    },
    {
      path: '/cementerios/abcementer',
      name: 'cementerios-abcementer',
      component: () => import('@/views/modules/cementerios/ABCementer.vue')
    },
    {
      path: '/cementerios/titulos',
      name: 'cementerios-titulos',
      component: () => import('@/views/modules/cementerios/Titulos.vue')
    },
    {
      path: '/cementerios/consultafol',
      name: 'cementerios-consultafol',
      component: () => import('@/views/modules/cementerios/ConsultaFol.vue')
    },
    {
      path: '/cementerios/abcpagos',
      name: 'cementerios-abcpagos',
      component: () => import('@/views/modules/cementerios/ABCPagos.vue')
    },
    {
      path: '/cementerios/liquidaciones',
      name: 'cementerios-liquidaciones',
      component: () => import('@/views/modules/cementerios/Liquidaciones.vue')
    },
    {
      path: '/cementerios/abcfolio',
      name: 'cementerios-abcfolio',
      component: () => import('@/views/modules/cementerios/ABCFolio.vue')
    },
    {
      path: '/cementerios/bonificaciones',
      name: 'cementerios-bonificaciones',
      component: () => import('@/views/modules/cementerios/Bonificaciones.vue')
    },
    {
      path: '/cementerios/descuentos',
      name: 'cementerios-descuentos',
      component: () => import('@/views/modules/cementerios/Descuentos.vue')
    },
    {
      path: '/cementerios/abcrecargos',
      name: 'cementerios-abcrecargos',
      component: () => import('@/views/modules/cementerios/ABCRecargos.vue')
    },
    {
      path: '/cementerios/trasladofol',
      name: 'cementerios-trasladofol',
      component: () => import('@/views/modules/cementerios/TrasladoFol.vue')
    },
    {
      path: '/cementerios/traslados',
      name: 'cementerios-traslados',
      component: () => import('@/views/modules/cementerios/Traslados.vue')
    },
    {
      path: '/cementerios/duplicados',
      name: 'cementerios-duplicados',
      component: () => import('@/views/modules/cementerios/Duplicados.vue')
    },
    {
      path: '/cementerios/multiplefecha',
      name: 'cementerios-multiplefecha',
      component: () => import('@/views/modules/cementerios/Multiplefecha.vue')
    },
    {
      path: '/cementerios/multiplenombre',
      name: 'cementerios-multiplenombre',
      component: () => import('@/views/modules/cementerios/MultipleNombre.vue')
    },
    {
      path: '/cementerios/multiplercm',
      name: 'cementerios-multiplercm',
      component: () => import('@/views/modules/cementerios/MultipleRCM.vue')
    },
    {
      path: '/cementerios/conindividual',
      name: 'cementerios-conindividual',
      component: () => import('@/views/modules/cementerios/ConIndividual.vue')
    },
    {
      path: '/cementerios/consultaguad',
      name: 'cementerios-consultaguad',
      component: () => import('@/views/modules/cementerios/ConsultaGuad.vue')
    },
    {
      path: '/cementerios/consultajardin',
      name: 'cementerios-consultajardin',
      component: () => import('@/views/modules/cementerios/ConsultaJardin.vue')
    },
    {
      path: '/cementerios/consultamezq',
      name: 'cementerios-consultamezq',
      component: () => import('@/views/modules/cementerios/ConsultaMezq.vue')
    },
    {
      path: '/cementerios/consultasandres',
      name: 'cementerios-consultasandres',
      component: () => import('@/views/modules/cementerios/ConsultaSAndres.vue')
    },
    {
      path: '/cementerios/estad-adeudo',
      name: 'cementerios-estad-adeudo',
      component: () => import('@/views/modules/cementerios/Estad_adeudo.vue')
    },
    {
      path: '/cementerios/list-mov',
      name: 'cementerios-list-mov',
      component: () => import('@/views/modules/cementerios/List_Mov.vue')
    },
    {
      path: '/cementerios/rep-a-cobrar',
      name: 'cementerios-rep-a-cobrar',
      component: () => import('@/views/modules/cementerios/Rep_a_Cobrar.vue')
    },
    {
      path: '/cementerios/rep-bon',
      name: 'cementerios-rep-bon',
      component: () => import('@/views/modules/cementerios/Rep_Bon.vue')
    },
    {
      path: '/cementerios/abcpagosxfol',
      name: 'cementerios-abcpagosxfol',
      component: () => import('@/views/modules/cementerios/ABCPagosxfol.vue')
    },
    {
      path: '/cementerios/consultarcm',
      name: 'cementerios-consultarcm',
      component: () => import('@/views/modules/cementerios/ConsultaRCM.vue')
    },
    {
      path: '/cementerios/consulta400',
      name: 'cementerios-consulta400',
      component: () => import('@/views/modules/cementerios/Consulta400.vue')
    },
    {
      path: '/cementerios/bonificacion1',
      name: 'cementerios-bonificacion1',
      component: () => import('@/views/modules/cementerios/Bonificacion1.vue')
    },
    {
      path: '/cementerios/consultanombre',
      name: 'cementerios-consultanombre',
      component: () => import('@/views/modules/cementerios/ConsultaNombre.vue')
    },
    {
      path: '/cementerios/rpttitulos',
      name: 'cementerios-rpttitulos',
      component: () => import('@/views/modules/cementerios/RptTitulos.vue')
    },
    {
      path: '/cementerios/titulossin',
      name: 'cementerios-titulossin',
      component: () => import('@/views/modules/cementerios/TitulosSin.vue')
    },
    {
      path: '/cementerios/trasladofolsin',
      name: 'cementerios-trasladofolsin',
      component: () => import('@/views/modules/cementerios/TrasladoFolSin.vue')
    },
    {
      path: '/cementerios/acceso',
      name: 'cementerios-acceso',
      component: () => import('@/views/modules/cementerios/Acceso.vue')
    },
    {
      path: '/cementerios/menu',
      name: 'cementerios-menu',
      component: () => import('@/views/modules/cementerios/Menu.vue')
    },
    {
      path: '/cementerios/modulo',
      name: 'cementerios-modulo',
      component: () => import('@/views/modules/cementerios/Modulo.vue')
    },
    {
      path: '/cementerios/chgpass',
      name: 'cementerios-chgpass',
      component: () => import('@/views/modules/cementerios/sfrm_chgpass.vue')
    },
    {
      path: '/cementerio',
      name: 'cementerio',
      component: () => import('@/views/modules/cementerios/index.vue')
    },
    // RUTAS ESTACIONAMIENTO EXCLUSIVO
    { path: '/estacionamiento-exclusivo', name: 'estacionamiento-exclusivo', component: () => import('@/views/modules/estacionamiento_exclusivo/Menu.vue') },
    { path: '/estacionamiento-exclusivo/acceso', name: 'estacionamiento-exclusivo-acceso', component: () => import('@/views/modules/estacionamiento_exclusivo/acceso.vue') },
    { path: '/estacionamiento-exclusivo/individual', name: 'estacionamiento-exclusivo-individual', component: () => import('@/views/modules/estacionamiento_exclusivo/Individual.vue') },
    { path: '/estacionamiento-exclusivo/individual-folio', name: 'estacionamiento-exclusivo-individual-folio', component: () => import('@/views/modules/estacionamiento_exclusivo/Individual_Folio.vue') },
    { path: '/estacionamiento-exclusivo/consulta-reg', name: 'estacionamiento-exclusivo-consulta-reg', component: () => import('@/views/modules/estacionamiento_exclusivo/ConsultaReg.vue') },
    { path: '/estacionamiento-exclusivo/cons-his', name: 'estacionamiento-exclusivo-cons-his', component: () => import('@/views/modules/estacionamiento_exclusivo/Cons_his.vue') },
    { path: '/estacionamiento-exclusivo/listados', name: 'estacionamiento-exclusivo-listados', component: () => import('@/views/modules/estacionamiento_exclusivo/Listados.vue') },
    { path: '/estacionamiento-exclusivo/listados-ade', name: 'estacionamiento-exclusivo-listados-ade', component: () => import('@/views/modules/estacionamiento_exclusivo/Listados_Ade.vue') },
    { path: '/estacionamiento-exclusivo/listados-sin-adereq', name: 'estacionamiento-exclusivo-listados-sin-adereq', component: () => import('@/views/modules/estacionamiento_exclusivo/ListadosSinAdereq.vue') },
    { path: '/estacionamiento-exclusivo/listx-reg', name: 'estacionamiento-exclusivo-listx-reg', component: () => import('@/views/modules/estacionamiento_exclusivo/ListxReg.vue') },
    { path: '/estacionamiento-exclusivo/listx-fec', name: 'estacionamiento-exclusivo-listx-fec', component: () => import('@/views/modules/estacionamiento_exclusivo/ListxFec.vue') },
    { path: '/estacionamiento-exclusivo/estdx-folio', name: 'estacionamiento-exclusivo-estdx-folio', component: () => import('@/views/modules/estacionamiento_exclusivo/EstadxFolio.vue') },
    { path: '/estacionamiento-exclusivo/modificar', name: 'estacionamiento-exclusivo-modificar', component: () => import('@/views/modules/estacionamiento_exclusivo/Modifcar.vue') },
    { path: '/estacionamiento-exclusivo/modificar-bien', name: 'estacionamiento-exclusivo-modificar-bien', component: () => import('@/views/modules/estacionamiento_exclusivo/Modificar_bien.vue') },
    { path: '/estacionamiento-exclusivo/modif-masiva', name: 'estacionamiento-exclusivo-modif-masiva', component: () => import('@/views/modules/estacionamiento_exclusivo/Modif_Masiva.vue') },
    { path: '/estacionamiento-exclusivo/facturacion', name: 'estacionamiento-exclusivo-facturacion', component: () => import('@/views/modules/estacionamiento_exclusivo/Facturacion.vue') },
    { path: '/estacionamiento-exclusivo/requerimientos', name: 'estacionamiento-exclusivo-requerimientos', component: () => import('@/views/modules/estacionamiento_exclusivo/Requerimientos.vue') },
    { path: '/estacionamiento-exclusivo/recuperacion', name: 'estacionamiento-exclusivo-recuperacion', component: () => import('@/views/modules/estacionamiento_exclusivo/Recuperacion.vue') },
    { path: '/estacionamiento-exclusivo/notificaciones', name: 'estacionamiento-exclusivo-notificaciones', component: () => import('@/views/modules/estacionamiento_exclusivo/Notificaciones.vue') },
    { path: '/estacionamiento-exclusivo/notificaciones-mes', name: 'estacionamiento-exclusivo-notificaciones-mes', component: () => import('@/views/modules/estacionamiento_exclusivo/NotificacionesMes.vue') },
    { path: '/estacionamiento-exclusivo/prenomina', name: 'estacionamiento-exclusivo-prenomina', component: () => import('@/views/modules/estacionamiento_exclusivo/Prenomina.vue') },
    { path: '/estacionamiento-exclusivo/reasignacion', name: 'estacionamiento-exclusivo-reasignacion', component: () => import('@/views/modules/estacionamiento_exclusivo/Reasignacion.vue') },
    { path: '/estacionamiento-exclusivo/ejecutores', name: 'estacionamiento-exclusivo-ejecutores', component: () => import('@/views/modules/estacionamiento_exclusivo/Ejecutores.vue') },
    { path: '/estacionamiento-exclusivo/abc-ejec', name: 'estacionamiento-exclusivo-abc-ejec', component: () => import('@/views/modules/estacionamiento_exclusivo/ABCEjec.vue') },
    { path: '/estacionamiento-exclusivo/lista-ejec', name: 'estacionamiento-exclusivo-lista-ejec', component: () => import('@/views/modules/estacionamiento_exclusivo/Lista_Eje.vue') },
    { path: '/estacionamiento-exclusivo/list-eje', name: 'estacionamiento-exclusivo-list-eje', component: () => import('@/views/modules/estacionamiento_exclusivo/List_Eje.vue') },
    { path: '/estacionamiento-exclusivo/lista-gastos-cob', name: 'estacionamiento-exclusivo-lista-gastos-cob', component: () => import('@/views/modules/estacionamiento_exclusivo/Lista_GastosCob.vue') },
    { path: '/estacionamiento-exclusivo/autoriza-des', name: 'estacionamiento-exclusivo-autoriza-des', component: () => import('@/views/modules/estacionamiento_exclusivo/AutorizaDes.vue') },
    { path: '/estacionamiento-exclusivo/carta-invitacion', name: 'estacionamiento-exclusivo-carta-invitacion', component: () => import('@/views/modules/estacionamiento_exclusivo/CartaInvitacion.vue') },
    { path: '/estacionamiento-exclusivo/cmult-emision', name: 'estacionamiento-exclusivo-cmult-emision', component: () => import('@/views/modules/estacionamiento_exclusivo/CMultEmision.vue') },
    { path: '/estacionamiento-exclusivo/cmult-folio', name: 'estacionamiento-exclusivo-cmult-folio', component: () => import('@/views/modules/estacionamiento_exclusivo/CMultFolio.vue') },
    { path: '/estacionamiento-exclusivo/exportar-excel', name: 'estacionamiento-exclusivo-exportar-excel', component: () => import('@/views/modules/estacionamiento_exclusivo/ExportarExcel.vue') },
    { path: '/estacionamiento-exclusivo/firma-electronica', name: 'estacionamiento-exclusivo-firma-electronica', component: () => import('@/views/modules/estacionamiento_exclusivo/FirmaElectronica.vue') },
    { path: '/estacionamiento-exclusivo/apremios-svn-expedientes', name: 'estacionamiento-exclusivo-apremios-svn-expedientes', component: () => import('@/views/modules/estacionamiento_exclusivo/ApremiosSvnExpedientes.vue') },
    { path: '/estacionamiento-exclusivo/apremios-svn-fases', name: 'estacionamiento-exclusivo-apremios-svn-fases', component: () => import('@/views/modules/estacionamiento_exclusivo/ApremiosSvnFases.vue') },
    { path: '/estacionamiento-exclusivo/apremios-svn-actuaciones', name: 'estacionamiento-exclusivo-apremios-svn-actuaciones', component: () => import('@/views/modules/estacionamiento_exclusivo/ApremiosSvnActuaciones.vue') },
    { path: '/estacionamiento-exclusivo/apremios-svn-notificaciones', name: 'estacionamiento-exclusivo-apremios-svn-notificaciones', component: () => import('@/views/modules/estacionamiento_exclusivo/ApremiosSvnNotificaciones.vue') },
    { path: '/estacionamiento-exclusivo/apremios-svn-pagos', name: 'estacionamiento-exclusivo-apremios-svn-pagos', component: () => import('@/views/modules/estacionamiento_exclusivo/ApremiosSvnPagos.vue') },
    { path: '/estacionamiento-exclusivo/apremios-svn-reportes', name: 'estacionamiento-exclusivo-apremios-svn-reportes', component: () => import('@/views/modules/estacionamiento_exclusivo/ApremiosSvnReportes.vue') },
    { path: '/estacionamiento-exclusivo/sfrm-chgpass', name: 'estacionamiento-exclusivo-sfrm-chgpass', component: () => import('@/views/modules/estacionamiento_exclusivo/sfrm_chgpass.vue') },
    // Rutas de Reportes Estacionamiento Exclusivo
    { path: '/estacionamiento-exclusivo/rprt-catal-eje', name: 'estacionamiento-exclusivo-rprt-catal-eje', component: () => import('@/views/modules/estacionamiento_exclusivo/RprtCATAL_EJE.vue') },
    { path: '/estacionamiento-exclusivo/rprt-estadx-folio', name: 'estacionamiento-exclusivo-rprt-estadx-folio', component: () => import('@/views/modules/estacionamiento_exclusivo/RprtEstadxfolio.vue') },
    { path: '/estacionamiento-exclusivo/rprt-list-eje', name: 'estacionamiento-exclusivo-rprt-list-eje', component: () => import('@/views/modules/estacionamiento_exclusivo/RprtList_Eje.vue') },
    { path: '/estacionamiento-exclusivo/rprt-listados', name: 'estacionamiento-exclusivo-rprt-listados', component: () => import('@/views/modules/estacionamiento_exclusivo/RprtListados.vue') },
    { path: '/estacionamiento-exclusivo/rprt-listax-fec', name: 'estacionamiento-exclusivo-rprt-listax-fec', component: () => import('@/views/modules/estacionamiento_exclusivo/RprtListaxFec.vue') },
    { path: '/estacionamiento-exclusivo/rprt-listax-reg-aseo', name: 'estacionamiento-exclusivo-rprt-listax-reg-aseo', component: () => import('@/views/modules/estacionamiento_exclusivo/RprtListaxRegAseo.vue') },
    { path: '/estacionamiento-exclusivo/rprt-listax-reg-estacionometro', name: 'estacionamiento-exclusivo-rprt-listax-reg-estacionometro', component: () => import('@/views/modules/estacionamiento_exclusivo/RprtListaxRegEstacionometro.vue') },
    { path: '/estacionamiento-exclusivo/rprt-listax-reg-mer', name: 'estacionamiento-exclusivo-rprt-listax-reg-mer', component: () => import('@/views/modules/estacionamiento_exclusivo/RprtListaxRegMer.vue') },
    { path: '/estacionamiento-exclusivo/rpt-fact-merc', name: 'estacionamiento-exclusivo-rpt-fact-merc', component: () => import('@/views/modules/estacionamiento_exclusivo/RptFact_Merc.vue') },
    { path: '/estacionamiento-exclusivo/rpt-lista-mercados', name: 'estacionamiento-exclusivo-rpt-lista-mercados', component: () => import('@/views/modules/estacionamiento_exclusivo/RptLista_mercados.vue') },
    { path: '/estacionamiento-exclusivo/rpt-listado-aseo', name: 'estacionamiento-exclusivo-rpt-listado-aseo', component: () => import('@/views/modules/estacionamiento_exclusivo/RptListado_Aseo.vue') },
    { path: '/estacionamiento-exclusivo/rpt-listax-reg-pub', name: 'estacionamiento-exclusivo-rpt-listax-reg-pub', component: () => import('@/views/modules/estacionamiento_exclusivo/RptListaxRegPub.vue') },
    { path: '/estacionamiento-exclusivo/rpt-prenomina', name: 'estacionamiento-exclusivo-rpt-prenomina', component: () => import('@/views/modules/estacionamiento_exclusivo/RptPrenomina.vue') },
    { path: '/estacionamiento-exclusivo/rpt-recup-aseo', name: 'estacionamiento-exclusivo-rpt-recup-aseo', component: () => import('@/views/modules/estacionamiento_exclusivo/RptRecup_Aseo.vue') },
    { path: '/estacionamiento-exclusivo/rpt-recup-merc', name: 'estacionamiento-exclusivo-rpt-recup-merc', component: () => import('@/views/modules/estacionamiento_exclusivo/RptRecup_Merc.vue') },
    { path: '/estacionamiento-exclusivo/rpt-req-aseo', name: 'estacionamiento-exclusivo-rpt-req-aseo', component: () => import('@/views/modules/estacionamiento_exclusivo/RptReq_Aseo.vue') },
    { path: '/estacionamiento-exclusivo/rpt-req-merc', name: 'estacionamiento-exclusivo-rpt-req-merc', component: () => import('@/views/modules/estacionamiento_exclusivo/RptReq_Merc.vue') },
    { path: '/estacionamiento-exclusivo/rpt-req-pba-aseo', name: 'estacionamiento-exclusivo-rpt-req-pba-aseo', component: () => import('@/views/modules/estacionamiento_exclusivo/RptReq_Pba_Aseo.vue') },
    { path: '/estacionamiento-exclusivo/rpt-req-pba', name: 'estacionamiento-exclusivo-rpt-req-pba', component: () => import('@/views/modules/estacionamiento_exclusivo/RptReq_pba.vue') },
    // Rutas de Listados Adeudos Forms
    { path: '/estacionamiento-exclusivo/listados-ade-aseo', name: 'estacionamiento-exclusivo-listados-ade-aseo', component: () => import('@/views/modules/estacionamiento_exclusivo/ListadosAdeAseoForm.vue') },
    { path: '/estacionamiento-exclusivo/listados-ade-exclusivos', name: 'estacionamiento-exclusivo-listados-ade-exclusivos', component: () => import('@/views/modules/estacionamiento_exclusivo/ListadosAdeExclusivosForm.vue') },
    { path: '/estacionamiento-exclusivo/listados-ade-infracciones', name: 'estacionamiento-exclusivo-listados-ade-infracciones', component: () => import('@/views/modules/estacionamiento_exclusivo/ListadosAdeInfraccionesForm.vue') },
    { path: '/estacionamiento-exclusivo/listados-ade-mercados', name: 'estacionamiento-exclusivo-listados-ade-mercados', component: () => import('@/views/modules/estacionamiento_exclusivo/ListadosAdeMercadosForm.vue') },
    { path: '/estacionamiento-exclusivo/listados-ade-publicos', name: 'estacionamiento-exclusivo-listados-ade-publicos', component: () => import('@/views/modules/estacionamiento_exclusivo/ListadosAdePublicosForm.vue') },
    // Rutas auxiliares
    { path: '/estacionamiento-exclusivo/menu', name: 'estacionamiento-exclusivo-menu', component: () => import('@/views/modules/estacionamiento_exclusivo/Menu.vue') },
    { path: '/estacionamiento-exclusivo/report-autor', name: 'estacionamiento-exclusivo-report-autor', component: () => import('@/views/modules/estacionamiento_exclusivo/ReportAutor.vue') },
    { path: '/estacionamiento-exclusivo/modulo-db', name: 'estacionamiento-exclusivo-modulo-db', component: () => import('@/views/modules/estacionamiento_exclusivo/ModuloDb.vue') },
    { path: '/estacionamiento-exclusivo/unit9', name: 'estacionamiento-exclusivo-unit9', component: () => import('@/views/modules/estacionamiento_exclusivo/UNIT9.vue') },
    { path: '/estacionamiento-exclusivo/loader', name: 'estacionamiento-exclusivo-loader', component: () => import('@/views/modules/estacionamiento_exclusivo/Loader.vue') },
    {
      path: '/mercados',
      name: 'mercados',
      component: () => import('@/views/modules/mercados/index.vue')
    },
    // RUTAS DE MERCADOS
    { path: '/mercados/padron-locales', name: 'mercados-padron-locales', component: () => import('@/views/modules/mercados/PadronLocales.vue') },
    { path: '/mercados/locales-mtto', name: 'mercados-locales-mtto', component: () => import('@/views/modules/mercados/LocalesMtto.vue') },
    { path: '/mercados/adeudos-locales', name: 'mercados-adeudos-locales', component: () => import('@/views/modules/mercados/AdeudosLocales.vue') },
    { path: '/mercados/alta-pagos', name: 'mercados-alta-pagos', component: () => import('@/views/modules/mercados/AltaPagos.vue') },
    { path: '/mercados/emision-locales', name: 'mercados-emision-locales', component: () => import('@/views/modules/mercados/EmisionLocales.vue') },
    { path: '/mercados/estad-pagos-adeudos', name: 'mercados-estad-pagos-adeudos', component: () => import('@/views/modules/mercados/EstadPagosyAdeudos.vue') },
    { path: '/mercados/carga-pag-locales', name: 'mercados-carga-pag-locales', component: () => import('@/views/modules/mercados/CargaPagLocales.vue') },
    { path: '/mercados/listados-locales', name: 'mercados-listados-locales', component: () => import('@/views/modules/mercados/ListadosLocales.vue') },
    { path: '/mercados/rpt-pagos-locales', name: 'mercados-rpt-pagos-locales', component: () => import('@/views/modules/mercados/RptPagosLocales.vue') },
    { path: '/mercados/padron-energia', name: 'mercados-padron-energia', component: () => import('@/views/modules/mercados/PadronEnergia.vue') },
    { path: '/mercados/energia-mtto', name: 'mercados-energia-mtto', component: () => import('@/views/modules/mercados/EnergiaMtto.vue') },
    { path: '/mercados/adeudos-energia', name: 'mercados-adeudos-energia', component: () => import('@/views/modules/mercados/AdeudosEnergia.vue') },
    { path: '/mercados/catalogo-mercados', name: 'mercados-catalogo-mercados', component: () => import('@/views/modules/mercados/CatalogoMercados.vue') },
    { path: '/mercados/consulta-datos-locales', name: 'mercados-consulta-datos-locales', component: () => import('@/views/modules/mercados/ConsultaDatosLocales.vue') },
    { path: '/mercados/consulta-datos-energia', name: 'mercados-consulta-datos-energia', component: () => import('@/views/modules/mercados/ConsultaDatosEnergia.vue') },
    { path: '/mercados/cuotas-mdo', name: 'mercados-cuotas-mdo', component: () => import('@/views/modules/mercados/CuotasMdo.vue') },
    { path: '/mercados/categoria', name: 'mercados-categoria', component: () => import('@/views/modules/mercados/Categoria.vue') },
    { path: '/mercados/giros', name: 'mercados-giros', component: () => import('@/views/modules/mercados/Giros.vue') },
    { path: '/mercados/secciones', name: 'mercados-secciones', component: () => import('@/views/modules/mercados/Secciones.vue') },
    { path: '/mercados/recaudadoras-mercados', name: 'mercados-recaudadoras-mercados', component: () => import('@/views/modules/mercados/RecaudadorasMercados.vue') },
    { path: '/mercados/zonas-mercados', name: 'mercados-zonas-mercados', component: () => import('@/views/modules/mercados/ZonasMercados.vue') },
    { path: '/mercados/reporte-general-mercados', name: 'mercados-reporte-general-mercados', component: () => import('@/views/modules/mercados/ReporteGeneralMercados.vue') },
    { path: '/mercados/padron-global', name: 'mercados-padron-global', component: () => import('@/views/modules/mercados/PadronGlobal.vue') },
    { path: '/mercados/alta-pagos-energia', name: 'mercados-alta-pagos-energia', component: () => import('@/views/modules/mercados/AltaPagosEnergia.vue') },
    { path: '/mercados/cons-pagos', name: 'mercados-cons-pagos', component: () => import('@/views/modules/mercados/ConsPagos.vue') },
    { path: '/mercados/pagos-individual', name: 'mercados-pagos-individual', component: () => import('@/views/modules/mercados/PagosIndividual.vue') },
    { path: '/mercados/cuotas-energia', name: 'mercados-cuotas-energia', component: () => import('@/views/modules/mercados/CuotasEnergia.vue') },
    { path: '/mercados/emision-energia', name: 'mercados-emision-energia', component: () => import('@/views/modules/mercados/EmisionEnergia.vue') },
    { path: '/mercados/cuotas-energia-mntto', name: 'mercados-cuotas-energia-mntto', component: () => import('@/views/modules/mercados/CuotasEnergiaMntto.vue') },
    { path: '/mercados/datos-convenio', name: 'mercados-datos-convenio', component: () => import('@/views/modules/mercados/DatosConvenio.vue') },
    { path: '/mercados/datos-individuales', name: 'mercados-datos-individuales', component: () => import('@/views/modules/mercados/DatosIndividuales.vue') },
    { path: '/mercados/estadisticas', name: 'mercados-estadisticas', component: () => import('@/views/modules/mercados/Estadisticas.vue') },
    { path: '/mercados/acceso', name: 'mercados-acceso', component: () => import('@/views/modules/mercados/Acceso.vue') },
    { path: '/mercados/catalogo-mntto', name: 'mercados-catalogo-mntto', component: () => import('@/views/modules/mercados/CatalogoMntto.vue') },
    { path: '/mercados/cons-requerimientos', name: 'mercados-cons-requerimientos', component: () => import('@/views/modules/mercados/ConsRequerimientos.vue') },
    { path: '/mercados/condonacion', name: 'mercados-condonacion', component: () => import('@/views/modules/mercados/Condonacion.vue') },
    { path: '/mercados/ade-global-locales', name: 'mercados-ade-global-locales', component: () => import('@/views/modules/mercados/AdeGlobalLocales.vue') },
    { path: '/mercados/ade-energia-grl', name: 'mercados-ade-energia-grl', component: () => import('@/views/modules/mercados/AdeEnergiaGrl.vue') },
    { path: '/mercados/adeudos-loc-grl', name: 'mercados-adeudos-loc-grl', component: () => import('@/views/modules/mercados/AdeudosLocGrl.vue') },
    { path: '/mercados/aut-carga-pagos', name: 'mercados-aut-carga-pagos', component: () => import('@/views/modules/mercados/AutCargaPagos.vue') },
    { path: '/mercados/aut-carga-pagos-mtto', name: 'mercados-aut-carga-pagos-mtto', component: () => import('@/views/modules/mercados/AutCargaPagosMtto.vue') },
    { path: '/mercados/carga-diversos-esp', name: 'mercados-carga-diversos-esp', component: () => import('@/views/modules/mercados/CargaDiversosEsp.vue') },
    { path: '/mercados/carga-pag-energia', name: 'mercados-carga-pag-energia', component: () => import('@/views/modules/mercados/CargaPagEnergia.vue') },
    { path: '/mercados/carga-pag-energia-elec', name: 'mercados-carga-pag-energia-elec', component: () => import('@/views/modules/mercados/CargaPagEnergiaElec.vue') },
    { path: '/mercados/carga-pag-especial', name: 'mercados-carga-pag-especial', component: () => import('@/views/modules/mercados/CargaPagEspecial.vue') },
    { path: '/mercados/carga-pag-mercado', name: 'mercados-carga-pag-mercado', component: () => import('@/views/modules/mercados/CargaPagMercado.vue') },
    { path: '/mercados/carga-pagos-texto', name: 'mercados-carga-pagos-texto', component: () => import('@/views/modules/mercados/CargaPagosTexto.vue') },
    { path: '/mercados/categoria-mntto', name: 'mercados-categoria-mntto', component: () => import('@/views/modules/mercados/CategoriaMntto.vue') },
    { path: '/mercados/cons-captura-energia', name: 'mercados-cons-captura-energia', component: () => import('@/views/modules/mercados/ConsCapturaEnergia.vue') },
    { path: '/mercados/cons-captura-fecha', name: 'mercados-cons-captura-fecha', component: () => import('@/views/modules/mercados/ConsCapturaFecha.vue') },
    { path: '/mercados/cons-captura-fecha-energia', name: 'mercados-cons-captura-fecha-energia', component: () => import('@/views/modules/mercados/ConsCapturaFechaEnergia.vue') },
    { path: '/mercados/cons-captura-merc', name: 'mercados-cons-captura-merc', component: () => import('@/views/modules/mercados/ConsCapturaMerc.vue') },
    { path: '/mercados/cons-pagos-energia', name: 'mercados-cons-pagos-energia', component: () => import('@/views/modules/mercados/ConsPagosEnergia.vue') },
    { path: '/mercados/cons-pagos-locales', name: 'mercados-cons-pagos-locales', component: () => import('@/views/modules/mercados/ConsPagosLocales.vue') },
    { path: '/mercados/consulta-general', name: 'mercados-consulta-general', component: () => import('@/views/modules/mercados/ConsultaGeneral.vue') },
    { path: '/mercados/cons-condonacion', name: 'mercados-cons-condonacion', component: () => import('@/views/modules/mercados/ConsCondonacion.vue') },
    { path: '/mercados/cons-condonacion-energia', name: 'mercados-cons-condonacion-energia', component: () => import('@/views/modules/mercados/ConsCondonacionEnergia.vue') },
    { path: '/mercados/cuotas-mdo-mntto', name: 'mercados-cuotas-mdo-mntto', component: () => import('@/views/modules/mercados/CuotasMdoMntto.vue') },
    { path: '/mercados/cve-cuota', name: 'mercados-cve-cuota', component: () => import('@/views/modules/mercados/CveCuota.vue') },
    { path: '/mercados/cve-diferencias', name: 'mercados-cve-diferencias', component: () => import('@/views/modules/mercados/CveDiferencias.vue') },
    { path: '/mercados/fecha-descuento', name: 'mercados-fecha-descuento', component: () => import('@/views/modules/mercados/FechaDescuento.vue') },
    { path: '/mercados/fechas-descuento-mntto', name: 'mercados-fechas-descuento-mntto', component: () => import('@/views/modules/mercados/FechasDescuentoMntto.vue') },
    { path: '/mercados/recargos', name: 'mercados-recargos', component: () => import('@/views/modules/mercados/Recargos.vue') },
    { path: '/mercados/datos-movimientos', name: 'mercados-datos-movimientos', component: () => import('@/views/modules/mercados/DatosMovimientos.vue') },
    { path: '/mercados/datos-requerimientos', name: 'mercados-datos-requerimientos', component: () => import('@/views/modules/mercados/DatosRequerimientos.vue') },
    { path: '/mercados/locales-modif', name: 'mercados-locales-modif', component: () => import('@/views/modules/mercados/LocalesModif.vue') },
    { path: '/mercados/energia-modif', name: 'mercados-energia-modif', component: () => import('@/views/modules/mercados/EnergiaModif.vue') },
    { path: '/mercados/emision-libertad', name: 'mercados-emision-libertad', component: () => import('@/views/modules/mercados/EmisionLibertad.vue') },
    { path: '/mercados/pagos-ene-cons', name: 'mercados-pagos-ene-cons', component: () => import('@/views/modules/mercados/PagosEneCons.vue') },
    { path: '/mercados/pagos-loc-grl', name: 'mercados-pagos-loc-grl', component: () => import('@/views/modules/mercados/PagosLocGrl.vue') },
    { path: '/mercados/prescripcion', name: 'mercados-prescripcion', component: () => import('@/views/modules/mercados/Prescripcion.vue') },
    { path: '/mercados/rep-adeud-cond', name: 'mercados-rep-adeud-cond', component: () => import('@/views/modules/mercados/RepAdeudCond.vue') },
    { path: '/mercados/rpt-ade-energia-grl', name: 'mercados-rpt-ade-energia-grl', component: () => import('@/views/modules/mercados/RptAdeEnergiaGrl.vue') },
    { path: '/mercados/rpt-adeudos-locales', name: 'mercados-rpt-adeudos-locales', component: () => import('@/views/modules/mercados/RptAdeudosLocales.vue') },
    { path: '/mercados/rpt-adeudos-energia', name: 'mercados-rpt-adeudos-energia', component: () => import('@/views/modules/mercados/RptAdeudosEnergia.vue') },
    { path: '/mercados/rpt-adeudos-anteriores', name: 'mercados-rpt-adeudos-anteriores', component: () => import('@/views/modules/mercados/RptAdeudosAnteriores.vue') },
    { path: '/mercados/rpt-adeudos-abastos1998', name: 'mercados-rpt-adeudos-abastos1998', component: () => import('@/views/modules/mercados/RptAdeudosAbastos1998.vue') },
    { path: '/mercados/rpt-desgloce-ade-porimporte', name: 'mercados-rpt-desgloce-ade-porimporte', component: () => import('@/views/modules/mercados/RptDesgloceAdeporImporte.vue') },
    { path: '/mercados/rpt-emision-locales', name: 'mercados-rpt-emision-locales', component: () => import('@/views/modules/mercados/RptEmisionLocales.vue') },
    { path: '/mercados/rpt-emision-rbos-abastos', name: 'mercados-rpt-emision-rbos-abastos', component: () => import('@/views/modules/mercados/RptEmisionRbosAbastos.vue') },
    { path: '/mercados/rpt-emision-laser', name: 'mercados-rpt-emision-laser', component: () => import('@/views/modules/mercados/RptEmisionLaser.vue') },
    { path: '/mercados/rpt-emision-energia', name: 'mercados-rpt-emision-energia', component: () => import('@/views/modules/mercados/RptEmisionEnergia.vue') },
    { path: '/mercados/rpt-factura-emision', name: 'mercados-rpt-factura-emision', component: () => import('@/views/modules/mercados/RptFacturaEmision.vue') },
    { path: '/mercados/rpt-factura-energia', name: 'mercados-rpt-factura-energia', component: () => import('@/views/modules/mercados/RptFacturaEnergia.vue') },
    { path: '/mercados/rpt-factura-glunes', name: 'mercados-rpt-factura-glunes', component: () => import('@/views/modules/mercados/RptFacturaGLunes.vue') },
    { path: '/mercados/rpt-padron-locales', name: 'mercados-rpt-padron-locales', component: () => import('@/views/modules/mercados/RptPadronLocales.vue') },
    { path: '/mercados/rpt-padron-energia', name: 'mercados-rpt-padron-energia', component: () => import('@/views/modules/mercados/RptPadronEnergia.vue') },
    { path: '/mercados/rpt-locales-giro', name: 'mercados-rpt-locales-giro', component: () => import('@/views/modules/mercados/RptLocalesGiro.vue') },
    { path: '/mercados/rpt-mercados', name: 'mercados-rpt-mercados', component: () => import('@/views/modules/mercados/RptMercados.vue') },
    { path: '/mercados/rpt-zonificacion', name: 'mercados-rpt-zonificacion', component: () => import('@/views/modules/mercados/RptZonificacion.vue') },
    { path: '/mercados/rpt-movimientos', name: 'mercados-rpt-movimientos', component: () => import('@/views/modules/mercados/RptMovimientos.vue') },
    { path: '/mercados/ingreso-captura', name: 'mercados-ingreso-captura', component: () => import('@/views/modules/mercados/IngresoCaptura.vue') },
    { path: '/mercados/ingreso-lib', name: 'mercados-ingreso-lib', component: () => import('@/views/modules/mercados/IngresoLib.vue') },
    { path: '/mercados/rpt-ingreso-zonificado', name: 'mercados-rpt-ingreso-zonificado', component: () => import('@/views/modules/mercados/RptIngresoZonificado.vue') },
    { path: '/mercados/rpt-ingresos', name: 'mercados-rpt-ingresos', component: () => import('@/views/modules/mercados/RptIngresos.vue') },
    { path: '/mercados/rpt-ingresos-energia', name: 'mercados-rpt-ingresos-energia', component: () => import('@/views/modules/mercados/RptIngresosEnergia.vue') },
    { path: '/mercados/rpt-pagos-ano', name: 'mercados-rpt-pagos-ano', component: () => import('@/views/modules/mercados/RptPagosAno.vue') },
    { path: '/mercados/rpt-pagos-caja', name: 'mercados-rpt-pagos-caja', component: () => import('@/views/modules/mercados/RptPagosCaja.vue') },
    { path: '/mercados/rpt-pagos-detalle', name: 'mercados-rpt-pagos-detalle', component: () => import('@/views/modules/mercados/RptPagosDetalle.vue') },
    { path: '/mercados/rpt-pagos-grl', name: 'mercados-rpt-pagos-grl', component: () => import('@/views/modules/mercados/RptPagosGrl.vue') },
    { path: '/mercados/rpt-estad-pagos-y-adeudos', name: 'mercados-rpt-estad-pagos-y-adeudos', component: () => import('@/views/modules/mercados/RptEstadPagosyAdeudos.vue') },
    { path: '/mercados/rpt-estadistica-adeudos', name: 'mercados-rpt-estadistica-adeudos', component: () => import('@/views/modules/mercados/RptEstadisticaAdeudos.vue') },
    { path: '/mercados/cuenta-publica', name: 'mercados-cuenta-publica', component: () => import('@/views/modules/mercados/CuentaPublica.vue') },
    { path: '/mercados/rpt-cuenta-publica', name: 'mercados-rpt-cuenta-publica', component: () => import('@/views/modules/mercados/RptCuentaPublica.vue') },
    { path: '/mercados/pagos-dif-ingresos', name: 'mercados-pagos-dif-ingresos', component: () => import('@/views/modules/mercados/PagosDifIngresos.vue') },
    { path: '/mercados/rpt-resumen-pagos', name: 'mercados-rpt-resumen-pagos', component: () => import('@/views/modules/mercados/RptResumenPagos.vue') },
    { path: '/mercados/rpt-saldos-locales', name: 'mercados-rpt-saldos-locales', component: () => import('@/views/modules/mercados/RptSaldosLocales.vue') },
    { path: '/mercados/rpt-fechas-vencimiento', name: 'mercados-rpt-fechas-vencimiento', component: () => import('@/views/modules/mercados/RptFechasVencimiento.vue') },
    { path: '/mercados/rpt-catalogo-merc', name: 'mercados-rpt-catalogo-merc', component: () => import('@/views/modules/mercados/RptCatalogoMerc.vue') },
    { path: '/mercados/paso-adeudos', name: 'mercados-paso-adeudos', component: () => import('@/views/modules/mercados/PasoAdeudos.vue') },
    { path: '/mercados/paso-ene', name: 'mercados-paso-ene', component: () => import('@/views/modules/mercados/PasoEne.vue') },
    { path: '/mercados/paso-mdos', name: 'mercados-paso-mdos', component: () => import('@/views/modules/mercados/PasoMdos.vue') },
    { path: '/mercados/menu', name: 'mercados-menu', component: () => import('@/views/modules/mercados/Menu.vue') },

    {
      path: '/multas-reglamentos',
      name: 'multas-reglamentos',
      component: () => import('@/views/modules/multas_reglamentos/index.vue')
    },
    {
      path: '/multas-reglamentos/actualiza-fecha-empresas',
      name: 'multas-reglamentos-actualiza-fecha-empresas',
      component: () => import('@/views/modules/multas_reglamentos/ActualizaFechaEmpresas.vue')
    },
    {
      path: '/multas-reglamentos/aplica-sdos-favor',
      name: 'multas-reglamentos-aplica-sdos-favor',
      component: () => import('@/views/modules/multas_reglamentos/AplicaSdosFavor.vue')
    },
    {
      path: '/multas-reglamentos/catastro-dm',
      name: 'multas-reglamentos-catastro-dm',
      component: () => import('@/views/modules/multas_reglamentos/CatastroDM.vue')
    },
    {
      path: '/multas-reglamentos/consreq400',
      name: 'multas-reglamentos-consreq400',
      component: () => import('@/views/modules/multas_reglamentos/ConsReq400.vue')
    },
    {
      path: '/multas-reglamentos/reqtrans',
      name: 'multas-reglamentos-reqtrans',
      component: () => import('@/views/modules/multas_reglamentos/ReqTrans.vue')
    },
    {
      path: '/multas-reglamentos/bloqueo-multa',
      name: 'multas-reglamentos-bloqueo-multa',
      component: () => import('@/views/modules/multas_reglamentos/BloqueoMulta.vue')
    },
    {
      path: '/multas-reglamentos/desc-derechos-merc',
      name: 'multas-reglamentos-desc-derechos-merc',
      component: () => import('@/views/modules/multas_reglamentos/DescDerechosMerc.vue')
    },
    {
      path: '/multas-reglamentos/empresas',
      name: 'multas-reglamentos-empresas',
      component: () => import('@/views/modules/multas_reglamentos/Empresas.vue')
    },
    {
      path: '/multas-reglamentos/gastos-transmision',
      name: 'multas-reglamentos-gastos-transmision',
      component: () => import('@/views/modules/multas_reglamentos/GastosTransmision.vue')
    },
    {
      path: '/multas-reglamentos/hastafrm',
      name: 'multas-reglamentos-hastafrm',
      component: () => import('@/views/modules/multas_reglamentos/Hastafrm.vue')
    },
    {
      path: '/multas-reglamentos/imprime-desctos',
      name: 'multas-reglamentos-imprime-desctos',
      component: () => import('@/views/modules/multas_reglamentos/ImprimeDesctos.vue')
    },
    {
      path: '/multas-reglamentos/list-ana',
      name: 'multas-reglamentos-list-ana',
      component: () => import('@/views/modules/multas_reglamentos/ListAna.vue')
    },
    {
      path: '/multas-reglamentos/lista-diferencias',
      name: 'multas-reglamentos-lista-diferencias',
      component: () => import('@/views/modules/multas_reglamentos/ListaDiferencias.vue')
    },
    {
      path: '/multas-reglamentos/listado-multiple',
      name: 'multas-reglamentos-listado-multiple',
      component: () => import('@/views/modules/multas_reglamentos/ListadoMultiple.vue')
    },
    {
      path: '/multas-reglamentos/modif-masiva',
      name: 'multas-reglamentos-modif-masiva',
      component: () => import('@/views/modules/multas_reglamentos/ModifMasiva.vue')
    },
    {
      path: '/multas-reglamentos/multas-dm',
      name: 'multas-reglamentos-multas-dm',
      component: () => import('@/views/modules/multas_reglamentos/MultasDM.vue')
    },
    {
      path: '/multas-reglamentos/otorgadescto',
      name: 'multas-reglamentos-otorgadescto',
      component: () => import('@/views/modules/multas_reglamentos/Otorgadescto.vue')
    },
    {
      path: '/multas-reglamentos/pagos-espe',
      name: 'multas-reglamentos-pagos-espe',
      component: () => import('@/views/modules/multas_reglamentos/PagosEspe.vue')
    },
    {
      path: '/multas-reglamentos/periodo-inicial',
      name: 'multas-reglamentos-periodo-inicial',
      component: () => import('@/views/modules/multas_reglamentos/PeriodoInicial.vue')
    },
    {
      path: '/multas-reglamentos/propuestatab',
      name: 'multas-reglamentos-propuestatab',
      component: () => import('@/views/modules/multas_reglamentos/Propuestatab.vue')
    },
    {
      path: '/multas-reglamentos/publicos-upd',
      name: 'multas-reglamentos-publicos-upd',
      component: () => import('@/views/modules/multas_reglamentos/Publicos_Upd.vue')
    },
    {
      path: '/multas-reglamentos/regsecy-mas',
      name: 'multas-reglamentos-regsecy-mas',
      component: () => import('@/views/modules/multas_reglamentos/RegSecyMas.vue')
    },
    {
      path: '/multas-reglamentos/rep-desc-impto',
      name: 'multas-reglamentos-rep-desc-impto',
      component: () => import('@/views/modules/multas_reglamentos/RepDescImpto.vue')
    },
    {
      path: '/multas-reglamentos/rep-oper',
      name: 'multas-reglamentos-rep-oper',
      component: () => import('@/views/modules/multas_reglamentos/RepOper.vue')
    },
    {
      path: '/multas-reglamentos/req',
      name: 'multas-reglamentos-req',
      component: () => import('@/views/modules/multas_reglamentos/Req.vue')
    },
    {
      path: '/multas-reglamentos/req-frm',
      name: 'multas-reglamentos-req-frm',
      component: () => import('@/views/modules/multas_reglamentos/ReqFrm.vue')
    },
    {
      path: '/multas-reglamentos/req-promocion',
      name: 'multas-reglamentos-req-promocion',
      component: () => import('@/views/modules/multas_reglamentos/ReqPromocion.vue')
    },
    {
      path: '/multas-reglamentos/requerimientos-dm',
      name: 'multas-reglamentos-requerimientos-dm',
      component: () => import('@/views/modules/multas_reglamentos/RequerimientosDM.vue')
    },
    {
      path: '/multas-reglamentos/requerx-cvecat',
      name: 'multas-reglamentos-requerx-cvecat',
      component: () => import('@/views/modules/multas_reglamentos/RequerxCvecat.vue')
    },
    {
      path: '/multas-reglamentos/resolucion-juez',
      name: 'multas-reglamentos-resolucion-juez',
      component: () => import('@/views/modules/multas_reglamentos/ResolucionJuez.vue')
    },
    {
      path: '/multas-reglamentos/sdosfavor-dm',
      name: 'multas-reglamentos-sdosfavor-dm',
      component: () => import('@/views/modules/multas_reglamentos/SdosFavorDM.vue')
    },
    {
      path: '/multas-reglamentos/sdosfavor-ctrlexp',
      name: 'multas-reglamentos-sdosfavor-ctrlexp',
      component: () => import('@/views/modules/multas_reglamentos/SdosFavor_CtrlExp.vue')
    },
    {
      path: '/multas-reglamentos/sdosfavor-pagos',
      name: 'multas-reglamentos-sdosfavor-pagos',
      component: () => import('@/views/modules/multas_reglamentos/SdosFavor_Pagos.vue')
    },
    {
      path: '/multas-reglamentos/sinligarfrm',
      name: 'multas-reglamentos-sinligarfrm',
      component: () => import('@/views/modules/multas_reglamentos/SinLigarFrm.vue')
    },
    {
      path: '/multas-reglamentos/sol-sdos-favor',
      name: 'multas-reglamentos-sol-sdos-favor',
      component: () => import('@/views/modules/multas_reglamentos/SolSdosFavor.vue')
    },
    {
      path: '/multas-reglamentos/tdm-conection',
      name: 'multas-reglamentos-tdm-conection',
      component: () => import('@/views/modules/multas_reglamentos/TDMConection.vue')
    },
    {
      path: '/multas-reglamentos/ubicodifica',
      name: 'multas-reglamentos-ubicodifica',
      component: () => import('@/views/modules/multas_reglamentos/Ubicodifica.vue')
    },
    // APREMIOS SVN (Estacionamiento Exclusivo)
    {
      path: '/apremiossvn',
      name: 'apremiossvn-index',
      component: () => import('@/views/modules/estacionamiento_exclusivo/index.vue')
    },
    {
      path: '/apremiossvn/expedientes',
      name: 'apremiossvn-expedientes',
      component: () => import('@/views/modules/estacionamiento_exclusivo/ApremiosSvnExpedientes.vue')
    },
    {
      path: '/apremiossvn/notificaciones',
      name: 'apremiossvn-notificaciones',
      component: () => import('@/views/modules/estacionamiento_exclusivo/ApremiosSvnNotificaciones.vue')
    },
    {
      path: '/apremiossvn/actuaciones',
      name: 'apremiossvn-actuaciones',
      component: () => import('@/views/modules/estacionamiento_exclusivo/ApremiosSvnActuaciones.vue')
    },
    {
      path: '/apremiossvn/pagos',
      name: 'apremiossvn-pagos',
      component: () => import('@/views/modules/estacionamiento_exclusivo/ApremiosSvnPagos.vue')
    },
    {
      path: '/apremiossvn/reportes',
      name: 'apremiossvn-reportes',
      component: () => import('@/views/modules/estacionamiento_exclusivo/ApremiosSvnReportes.vue')
    },
    {
      path: '/apremiossvn/fases',
      name: 'apremiossvn-fases',
      component: () => import('@/views/modules/estacionamiento_exclusivo/ApremiosSvnFases.vue')
    },
    {
      path: '/apremiossvn/:view',
      name: 'apremiossvn-loader',
      component: () => import('@/views/modules/estacionamiento_exclusivo/Loader.vue')
    },
    // Estacionamientos Privados (público)
    {
      path: '/estacionamientos/privados',
      name: 'estacionamientos-privados-index',
      component: () => import('@/views/modules/estacionamiento_publico/index.vue')
    },
    {
      path: '/multas-reglamentos/autdescto',
      name: 'multas-reglamentos-autdescto',
      component: () => import('@/views/modules/multas_reglamentos/autdescto.vue')
    },
    {
      path: '/multas-reglamentos/bloqctasreqfrm',
      name: 'multas-reglamentos-bloqctasreqfrm',
      component: () => import('@/views/modules/multas_reglamentos/bloqctasreqfrm.vue')
    },
    {
      path: '/multas-reglamentos/busque',
      name: 'multas-reglamentos-busque',
      component: () => import('@/views/modules/multas_reglamentos/busque.vue')
    },
    {
      path: '/multas-reglamentos/canc',
      name: 'multas-reglamentos-canc',
      component: () => import('@/views/modules/multas_reglamentos/canc.vue')
    },
    {
      path: '/multas-reglamentos/centrosfrm',
      name: 'multas-reglamentos-centrosfrm',
      component: () => import('@/views/modules/multas_reglamentos/centrosfrm.vue')
    },
    {
      path: '/multas-reglamentos/codificafrm',
      name: 'multas-reglamentos-codificafrm',
      component: () => import('@/views/modules/multas_reglamentos/codificafrm.vue')
    },
    {
      path: '/multas-reglamentos/conscentrosfrm',
      name: 'multas-reglamentos-conscentrosfrm',
      component: () => import('@/views/modules/multas_reglamentos/conscentrosfrm.vue')
    },
    {
      path: '/multas-reglamentos/consdesc',
      name: 'multas-reglamentos-consdesc',
      component: () => import('@/views/modules/multas_reglamentos/consdesc.vue')
    },
    {
      path: '/multas-reglamentos/:view',
      name: 'multas-reglamentos-loader',
      component: () => import('@/views/modules/multas_reglamentos/Loader.vue')
    },
    // OTRAS OBLIGACIONES - Menú Principal
    {
      path: '/otras_obligaciones/menu',
      name: 'otras-obligaciones-menu',
      component: () => import('@/views/modules/otras_obligaciones/Menu.vue')
    },
    // OTRAS OBLIGACIONES - Componentes Implementados
    {
      path: '/otras_obligaciones/apremios',
      name: 'otras-obligaciones-apremios',
      component: () => import('@/views/modules/otras_obligaciones/Apremios.vue')
    },
    {
      path: '/otras_obligaciones/aux-rep',
      name: 'otras-obligaciones-aux-rep',
      component: () => import('@/views/modules/otras_obligaciones/AuxRep.vue')
    },
    {
      path: '/otras_obligaciones/carga-cartera',
      name: 'otras-obligaciones-carga-cartera',
      component: () => import('@/views/modules/otras_obligaciones/CargaCartera.vue')
    },
    {
      path: '/otras_obligaciones/carga-valores',
      name: 'otras-obligaciones-carga-valores',
      component: () => import('@/views/modules/otras_obligaciones/CargaValores.vue')
    },
    {
      path: '/otras_obligaciones/etiquetas',
      name: 'otras-obligaciones-etiquetas',
      component: () => import('@/views/modules/otras_obligaciones/Etiquetas.vue')
    },
    {
      path: '/otras_obligaciones/gactualiza',
      name: 'otras-obligaciones-gactualiza',
      component: () => import('@/views/modules/otras_obligaciones/GActualiza.vue')
    },
    {
      path: '/otras_obligaciones/gadeudos',
      name: 'otras-obligaciones-gadeudos',
      component: () => import('@/views/modules/otras_obligaciones/GAdeudos.vue')
    },
    {
      path: '/otras_obligaciones/gadeudos-gral',
      name: 'otras-obligaciones-gadeudos-gral',
      component: () => import('@/views/modules/otras_obligaciones/GAdeudosGral.vue')
    },
    {
      path: '/otras_obligaciones/gadeudos-opc-mult',
      name: 'otras-obligaciones-gadeudos-opc-mult',
      component: () => import('@/views/modules/otras_obligaciones/GAdeudos_OpcMult.vue')
    },
    {
      path: '/otras_obligaciones/gadeudos-opc-mult-ra',
      name: 'otras-obligaciones-gadeudos-opc-mult-ra',
      component: () => import('@/views/modules/otras_obligaciones/GAdeudos_OpcMult_RA.vue')
    },
    {
      path: '/otras_obligaciones/gbaja',
      name: 'otras-obligaciones-gbaja',
      component: () => import('@/views/modules/otras_obligaciones/GBaja.vue')
    },
    {
      path: '/otras_obligaciones/gconsulta',
      name: 'otras-obligaciones-gconsulta',
      component: () => import('@/views/modules/otras_obligaciones/GConsulta.vue')
    },
    {
      path: '/otras_obligaciones/gconsulta2',
      name: 'otras-obligaciones-gconsulta2',
      component: () => import('@/views/modules/otras_obligaciones/GConsulta2.vue')
    },
    {
      path: '/otras_obligaciones/gfacturacion',
      name: 'otras-obligaciones-gfacturacion',
      component: () => import('@/views/modules/otras_obligaciones/GFacturacion.vue')
    },
    {
      path: '/otras_obligaciones/gnuevos',
      name: 'otras-obligaciones-gnuevos',
      component: () => import('@/views/modules/otras_obligaciones/GNuevos.vue')
    },
    {
      path: '/otras_obligaciones/grep-padron',
      name: 'otras-obligaciones-grep-padron',
      component: () => import('@/views/modules/otras_obligaciones/GRep_Padron.vue')
    },
    {
      path: '/otras_obligaciones/ractualiza',
      name: 'otras-obligaciones-ractualiza',
      component: () => import('@/views/modules/otras_obligaciones/RActualiza.vue')
    },
    {
      path: '/otras_obligaciones/radeudos',
      name: 'otras-obligaciones-radeudos',
      component: () => import('@/views/modules/otras_obligaciones/RAdeudos.vue')
    },
    {
      path: '/otras_obligaciones/radeudos-opc-mult',
      name: 'otras-obligaciones-radeudos-opc-mult',
      component: () => import('@/views/modules/otras_obligaciones/RAdeudos_OpcMult.vue')
    },
    {
      path: '/otras_obligaciones/rbaja',
      name: 'otras-obligaciones-rbaja',
      component: () => import('@/views/modules/otras_obligaciones/RBaja.vue')
    },
    {
      path: '/otras_obligaciones/rconsulta',
      name: 'otras-obligaciones-rconsulta',
      component: () => import('@/views/modules/otras_obligaciones/RConsulta.vue')
    },
    {
      path: '/otras_obligaciones/rfacturacion',
      name: 'otras-obligaciones-rfacturacion',
      component: () => import('@/views/modules/otras_obligaciones/RFacturacion.vue')
    },
    {
      path: '/otras_obligaciones/rnuevos',
      name: 'otras-obligaciones-rnuevos',
      component: () => import('@/views/modules/otras_obligaciones/RNuevos.vue')
    },
    {
      path: '/otras_obligaciones/rpagados',
      name: 'otras-obligaciones-rpagados',
      component: () => import('@/views/modules/otras_obligaciones/RPagados.vue')
    },
    {
      path: '/otras_obligaciones/rrep-padron',
      name: 'otras-obligaciones-rrep-padron',
      component: () => import('@/views/modules/otras_obligaciones/RRep_Padron.vue')
    },
    {
      path: '/otras_obligaciones/rubros',
      name: 'otras-obligaciones-rubros',
      component: () => import('@/views/modules/otras_obligaciones/Rubros.vue')
    },
    {
      path: '/padron-licencias',
      name: 'padron-licencias',
      component: () => import('@/views/modules/padron_licencias/index.vue')
    },
    {
      path: '/padron-licencias/consulta-usuarios',
      name: 'consulta-usuarios',
      component: () => import('@/views/modules/padron_licencias/consultausuariosfrm.vue')
    },
    {
      path: '/padron-licencias/consulta-licencias',
      name: 'consulta-licencias',
      component: () => import('@/views/modules/padron_licencias/consultaLicenciafrm.vue')
    },
    {
      path: '/padron-licencias/consulta-anuncios',
      name: 'consulta-anuncios',
      component: () => import('@/views/modules/padron_licencias/consultaAnunciofrm.vue')
    },
    {
      path: '/padron-licencias/modificacion-licencias',
      name: 'modificacion-licencias',
      component: () => import('@/views/modules/padron_licencias/modlicfrm.vue')
    },
    {
      path: '/padron-licencias/detalle-licencia',
      name: 'detalle-licencia',
      component: () => import('@/views/modules/padron_licencias/DetalleLicencia.vue')
    },
    {
      path: '/padron-licencias/detalle-anuncio',
      name: 'detalle-anuncio',
      component: () => import('@/views/modules/padron_licencias/DetalleAnuncio.vue')
    },
    {
      path: '/padron-licencias/modificacion-tramites/:id?',
      name: 'modificacion-tramites',
      component: () => import('@/views/modules/padron_licencias/modtramitefrm.vue')
    },
    {
      path: '/padron-licencias/consulta-tramites',
      name: 'consulta-tramites',
      component: () => import('@/views/modules/padron_licencias/ConsultaTramitefrm.vue')
    },
    {
      path: '/padron-licencias/solicitud-numero-oficial',
      name: 'solicitud-numero-oficial',
      component: () => import('@/views/modules/padron_licencias/constanciaNoOficialfrm.vue')
    },
    {
      path: '/padron-licencias/constancias',
      name: 'constancias',
      component: () => import('@/views/modules/padron_licencias/constanciafrm.vue')
    },
    {
      path: '/padron-licencias/dictamenes',
      name: 'dictamenes',
      component: () => import('@/views/modules/padron_licencias/dictamenfrm.vue')
    },
    {
      path: '/padron-licencias/baja-licencia',
      name: 'baja-licencia',
      component: () => import('@/views/modules/padron_licencias/bajaLicenciafrm.vue')
    },
    {
      path: '/padron-licencias/cancelacion-tramites',
      name: 'cancelacion-tramites',
      component: () => import('@/views/modules/padron_licencias/cancelaTramitefrm.vue')
    },
    {
      path: '/padron-licencias/bloqueo-domicilios',
      name: 'bloqueo-domicilios',
      component: () => import('@/views/modules/padron_licencias/bloqueoDomiciliosfrm.vue')
    },
    {
      path: '/padron-licencias/bloqueo-rfc',
      name: 'bloqueo-rfc',
      component: () => import('@/views/modules/padron_licencias/bloqueoRFCfrm.vue')
    },
    {
      path: '/padron-licencias/catalogo-giros',
      name: 'catalogo-giros',
      component: () => import('@/views/modules/padron_licencias/catalogogirosfrm.vue')
    },
    {
      path: '/padron-licencias/busqueda-giros',
      name: 'busqueda-giros',
      component: () => import('@/views/modules/padron_licencias/buscagirofrm.vue')
    },
    {
      path: '/padron-licencias/catalogo-actividades',
      name: 'catalogo-actividades',
      component: () => import('@/views/modules/padron_licencias/CatalogoActividadesFrm.vue')
    },
    {
      path: '/padron-licencias/catalogo-requisitos',
      name: 'catalogo-requisitos',
      component: () => import('@/views/modules/padron_licencias/CatRequisitos.vue')
    },
    {
      path: '/padron-licencias/grupos-licencias',
      name: 'grupos-licencias',
      component: () => import('@/views/modules/padron_licencias/gruposLicenciasfrm.vue')
    },
    {
      path: '/padron-licencias/cruces-calles',
      name: 'cruces-calles',
      component: () => import('@/views/modules/padron_licencias/Cruces.vue')
    },
    {
      path: '/padron-licencias/grupos-licencias-abc',
      name: 'grupos-licencias-abc',
      component: () => import('@/views/modules/padron_licencias/GruposLicenciasAbcfrm.vue')
    },
    {
      path: '/padron-licencias/zona-anuncio',
      name: 'zona-anuncio',
      component: () => import('@/views/modules/padron_licencias/ZonaAnuncio.vue')
    },
    {
      path: '/padron-licencias/busqueda-actividad',
      name: 'busqueda-actividad',
      component: () => import('@/views/modules/padron_licencias/BusquedaActividadFrm.vue')
    },
    {
      path: '/padron-licencias/busqueda-scian',
      name: 'busqueda-scian',
      component: () => import('@/views/modules/padron_licencias/BusquedaScianFrm.vue')
    },
    {
      path: '/padron-licencias/busqueda-general',
      name: 'busqueda-general',
      component: () => import('@/views/modules/padron_licencias/busque.vue')
    },
    {
      path: '/padron-licencias/bloquear-licencia',
      name: 'bloquear-licencia',
      component: () => import('@/views/modules/padron_licencias/BloquearLicenciafrm.vue')
    },
    {
      path: '/padron-licencias/bloquear-tramite',
      name: 'bloquear-tramite',
      component: () => import('@/views/modules/padron_licencias/BloquearTramitefrm.vue')
    },
    {
      path: '/padron-licencias/bloquear-anuncio',
      name: 'bloquear-anuncio',
      component: () => import('@/views/modules/padron_licencias/BloquearAnunciorm.vue')
    },
    {
      path: '/padron-licencias/baja-anuncio',
      name: 'baja-anuncio',
      component: () => import('@/views/modules/padron_licencias/bajaAnunciofrm.vue')
    },
    {
      path: '/padron-licencias/reactivar-tramite',
      name: 'reactivar-tramite',
      component: () => import('@/views/modules/padron_licencias/ReactivaTramite.vue')
    },
    {
      path: '/padron-licencias/certificaciones',
      name: 'certificaciones',
      component: () => import('@/views/modules/padron_licencias/certificacionesfrm.vue')
    },
    {
      path: '/padron-licencias/agenda-visitas',
      name: 'agenda-visitas',
      component: () => import('@/views/modules/padron_licencias/Agendavisitasfrm.vue')
    },
    {
      path: '/padron-licencias/registro-solicitud',
      name: 'registro-solicitud',
      component: () => import('@/views/modules/padron_licencias/RegistroSolicitud.vue')
    },
    {
      path: '/padron-licencias/dictamen-uso-suelo',
      name: 'dictamen-uso-suelo',
      component: () => import('@/views/modules/padron_licencias/dictamenusodesuelo.vue')
    },
    {
      path: '/padron-licencias/formatos-ecologia',
      name: 'formatos-ecologia',
      component: () => import('@/views/modules/padron_licencias/formatosEcologiafrm.vue')
    },
    {
      path: '/padron-licencias/documentos',
      name: 'documentos',
      component: () => import('@/views/modules/padron_licencias/doctosfrm.vue')
    },
    {
      path: '/padron-licencias/fecha-seguimiento',
      name: 'fecha-seguimiento',
      component: () => import('@/views/modules/padron_licencias/fechasegfrm.vue')
    },
    {
      path: '/padron-licencias/firma-usuario',
      name: 'firma-usuario',
      component: () => import('@/views/modules/padron_licencias/firmausuario.vue')
    },
    {
      path: '/padron-licencias/liga-anuncio',
      name: 'liga-anuncio',
      component: () => import('@/views/modules/padron_licencias/ligaAnunciofrm.vue')
    },
    {
      path: '/padron-licencias/liga-requisitos',
      name: 'liga-requisitos',
      component: () => import('@/views/modules/padron_licencias/LigaRequisitos.vue')
    },
    {
      path: '/padron-licencias/modific-adeudo',
      name: 'modific-adeudo',
      component: () => import('@/views/modules/padron_licencias/modlicAdeudofrm.vue')
    },
    {
      path: '/padron-licencias/prepago',
      name: 'prepago',
      component: () => import('@/views/modules/padron_licencias/prepagofrm.vue')
    },
    {
      path: '/padron-licencias/propietarios-hologramas',
      name: 'propietarios-hologramas',
      component: () => import('@/views/modules/padron_licencias/prophologramasfrm.vue')
    },
    {
      path: '/padron-licencias/responsivas',
      name: 'responsivas',
      component: () => import('@/views/modules/padron_licencias/Responsivafrm.vue')
    },
    {
      path: '/padron-licencias/hasta',
      name: 'hasta',
      component: () => import('@/views/modules/padron_licencias/Hastafrm.vue')
    },
    {
      path: '/padron-licencias/cartografia-catastral',
      name: 'cartografia-catastral',
      component: () => import('@/views/modules/padron_licencias/cartonva.vue')
    },
    {
      path: '/padron-licencias/carga-predios',
      name: 'carga-predios',
      component: () => import('@/views/modules/padron_licencias/carga.vue')
    },
    {
      path: '/padron-licencias/imp-licencia-reglamentada',
      name: 'imp-licencia-reglamentada',
      component: () => import('@/views/modules/padron_licencias/ImpLicenciaReglamentadaFrm.vue')
    },
    {
      path: '/padron-licencias/imp-oficio',
      name: 'imp-oficio',
      component: () => import('@/views/modules/padron_licencias/ImpOficiofrm.vue')
    },
    {
      path: '/padron-licencias/imp-recibo',
      name: 'imp-recibo',
      component: () => import('@/views/modules/padron_licencias/ImpRecibofrm.vue')
    },
    {
      path: '/padron-licencias/reporte-documentos',
      name: 'reporte-documentos',
      component: () => import('@/views/modules/padron_licencias/repdoc.vue')
    },
    {
      path: '/padron-licencias/reporte-estadisticos',
      name: 'reporte-estadisticos',
      component: () => import('@/views/modules/padron_licencias/repEstadisticosLicfrm.vue')
    },
    {
      path: '/padron-licencias/reporte-estado',
      name: 'reporte-estado',
      component: () => import('@/views/modules/padron_licencias/repestado.vue')
    },
    {
      path: '/padron-licencias/reporte-suspendidas',
      name: 'reporte-suspendidas',
      component: () => import('@/views/modules/padron_licencias/repsuspendidasfrm.vue')
    },
    {
      path: '/padron-licencias/reporte-anuncios-excel',
      name: 'reporte-anuncios-excel',
      component: () => import('@/views/modules/padron_licencias/ReporteAnunExcelfrm.vue')
    },
    {
      path: '/padron-licencias/catastro-dm',
      name: 'catastro-dm',
      component: () => import('@/views/modules/padron_licencias/CatastroDM.vue')
    },
    {
      path: '/padron-licencias/propuesta-tabulador',
      name: 'propuesta-tabulador',
      component: () => import('@/views/modules/padron_licencias/Propuestatab.vue')
    },
    {
      path: '/padron-licencias/empresas',
      name: 'empresas',
      component: () => import('@/views/modules/padron_licencias/empresasfrm.vue')
    },
    {
      path: '/padron-licencias/carga-datos',
      name: 'carga-datos',
      component: () => import('@/views/modules/padron_licencias/cargadatosfrm.vue')
    },
    {
      path: '/padron-licencias/semaforo',
      name: 'semaforo',
      component: () => import('@/views/modules/padron_licencias/Semaforo.vue')
    },
    {
      path: '/padron-licencias/formabuscalle',
      name: 'formabuscalle',
      component: () => import('@/views/modules/padron_licencias/formabuscalle.vue')
    },
    {
      path: '/padron-licencias/formabuscolonia',
      name: 'formabuscolonia',
      component: () => import('@/views/modules/padron_licencias/formabuscolonia.vue')
    },
    {
      path: '/padron-licencias/frmselcalle',
      name: 'frmselcalle',
      component: () => import('@/views/modules/padron_licencias/frmselcalle.vue')
    },
    {
      path: '/padron-licencias/sfrm-chgfirma',
      name: 'sfrm-chgfirma',
      component: () => import('@/views/modules/padron_licencias/sfrm_chgfirma.vue')
    },
    {
      path: '/padron-licencias/tipobloqueo',
      name: 'tipobloqueo',
      component: () => import('@/views/modules/padron_licencias/tipobloqueofrm.vue')
    },
    {
      path: '/padron-licencias/tramite-baja-anuncio',
      name: 'tramite-baja-anuncio',
      component: () => import('@/views/modules/padron_licencias/TramiteBajaAnun.vue')
    },
    {
      path: '/padron-licencias/tramite-baja-licencia',
      name: 'tramite-baja-licencia',
      component: () => import('@/views/modules/padron_licencias/TramiteBajaLic.vue')
    },
    {
      path: '/padron-licencias/observaciones',
      name: 'observaciones',
      component: () => import('@/views/modules/padron_licencias/observacionfrm.vue')
    },
    {
      path: '/padron-licencias/licencias-vigentes',
      name: 'licencias-vigentes',
      component: () => import('@/views/modules/padron_licencias/LicenciasVigentesfrm.vue')
    },
    {
      path: '/padron-licencias/sfrm-chgpass',
      name: 'sfrm-chgpass',
      component: () => import('@/views/modules/padron_licencias/sfrm_chgpass.vue')
    },
    {
      path: '/padron-licencias/grupos-anuncios',
      name: 'grupos-anuncios',
      component: () => import('@/views/modules/padron_licencias/gruposAnunciosfrm.vue')
    },
    {
      path: '/padron-licencias/grupos-anuncios-abc',
      name: 'grupos-anuncios-abc',
      component: () => import('@/views/modules/padron_licencias/GruposAnunciosAbcfrm.vue')
    },
    {
      path: '/padron-licencias/zona-licencia',
      name: 'zona-licencia',
      component: () => import('@/views/modules/padron_licencias/ZonaLicencia.vue')
    },
    {
      path: '/padron-licencias/privilegios',
      name: 'privilegios',
      component: () => import('@/views/modules/padron_licencias/privilegios.vue')
    },
    {
      path: '/padron-licencias/unidad-img',
      name: 'unidad-img',
      component: () => import('@/views/modules/padron_licencias/UnidadImg.vue')
    },
    {
      path: '/padron-licencias/dependencias',
      name: 'dependencias',
      component: () => import('@/views/modules/padron_licencias/dependenciasfrm.vue')
    },
    {
      path: '/padron-licencias/estatus',
      name: 'estatus',
      component: () => import('@/views/modules/padron_licencias/estatusfrm.vue')
    },
    {
      path: '/padron-licencias/giros-vigentes-cte-xgiro',
      name: 'giros-vigentes-cte-xgiro',
      component: () => import('@/views/modules/padron_licencias/girosVigentesCteXgirofrm.vue')
    },
    {
      path: '/padron-licencias/consulta-licencias-400',
      name: 'consulta-licencias-400',
      component: () => import('@/views/modules/padron_licencias/consLic400frm.vue')
    },
    {
      path: '/padron-licencias/consulta-anuncios-400',
      name: 'consulta-anuncios-400',
      component: () => import('@/views/modules/padron_licencias/consAnun400frm.vue')
    },
    {
      path: '/padron-licencias/historial-bloqueo-domicilios',
      name: 'historial-bloqueo-domicilios',
      component: () => import('@/views/modules/padron_licencias/h_bloqueoDomiciliosfrm.vue')
    },
    {
      path: '/padron-licencias/giros-con-adeudo',
      name: 'giros-con-adeudo',
      component: () => import('@/views/modules/padron_licencias/GirosDconAdeudofrm.vue')
    },
    {
      path: '/padron-licencias/impresion-licencias-reglamentadas',
      name: 'impresion-licencias-reglamentadas',
      component: () => import('@/views/modules/padron_licencias/frmImpLicenciaReglamentada.vue')
    },
    {
      path: '/padron-licencias/carga-imagenes',
      name: 'carga-imagenes',
      component: () => import('@/views/modules/padron_licencias/carga_imagen.vue')
    },
    {
      path: '/padron-licencias/firma-digital',
      name: 'firma-digital',
      component: () => import('@/views/modules/padron_licencias/firma.vue')
    },
    {
      path: '/padron-licencias/registro-historico',
      name: 'registro-historico',
      component: () => import('@/views/modules/padron_licencias/regHfrm.vue')
    },
    {
      path: '/padron-licencias/sgc-v2',
      name: 'sgc-v2',
      component: () => import('@/views/modules/padron_licencias/SGCv2.vue')
    },
    {
      path: '/padron-licencias/tdm-conexion',
      name: 'tdm-conexion',
      component: () => import('@/views/modules/padron_licencias/TDMConection.vue')
    },
    {
      path: '/padron-licencias/navegador-web',
      name: 'navegador-web',
      component: () => import('@/views/modules/padron_licencias/webBrowser.vue')
    },
    {
      path: '/padron-licencias/dialogo-giros',
      name: 'dialogo-giros',
      component: () => import('@/views/modules/padron_licencias/grs_dlg.vue')
    },
    {
      path: '/padron-licencias/bienvenida',
      name: 'bienvenida',
      component: () => import('@/views/modules/padron_licencias/psplash.vue')
    },
    {
      path: '/padron-licencias/imp-licencia-reglamentada',
      name: 'imp-licencia-reglamentada',
      component: () => import('@/views/modules/padron_licencias/ImpLicenciaReglamentada.vue')
    },
    // RUTAS DE OTRAS OBLIGACIONES
    { path: '/otras-obligaciones', name: 'otras-obligaciones', component: () => import('@/views/modules/otras_obligaciones/index.vue') },
    { path: '/otras-obligaciones/menu', name: 'otras-obligaciones-menu', component: () => import('@/views/modules/otras_obligaciones/Menu.vue') },
    { path: '/otras-obligaciones/gnuevos', name: 'otras-obligaciones-gnuevos', component: () => import('@/views/modules/otras_obligaciones/GNuevos.vue') },
    { path: '/otras-obligaciones/gconsulta', name: 'otras-obligaciones-gconsulta', component: () => import('@/views/modules/otras_obligaciones/GConsulta.vue') },
    { path: '/otras-obligaciones/gconsulta2', name: 'otras-obligaciones-gconsulta2', component: () => import('@/views/modules/otras_obligaciones/GConsulta2.vue') },
    { path: '/otras-obligaciones/gactualiza', name: 'otras-obligaciones-gactualiza', component: () => import('@/views/modules/otras_obligaciones/GActualiza.vue') },
    { path: '/otras-obligaciones/gbaja', name: 'otras-obligaciones-gbaja', component: () => import('@/views/modules/otras_obligaciones/GBaja.vue') },
    { path: '/otras-obligaciones/gadeudos', name: 'otras-obligaciones-gadeudos', component: () => import('@/views/modules/otras_obligaciones/GAdeudos.vue') },
    { path: '/otras-obligaciones/gadeudos-gral', name: 'otras-obligaciones-gadeudos-gral', component: () => import('@/views/modules/otras_obligaciones/GAdeudosGral.vue') },
    { path: '/otras-obligaciones/gadeudos-opc-mult', name: 'otras-obligaciones-gadeudos-opc-mult', component: () => import('@/views/modules/otras_obligaciones/GAdeudos_OpcMult.vue') },
    { path: '/otras-obligaciones/gadeudos-opc-mult-ra', name: 'otras-obligaciones-gadeudos-opc-mult-ra', component: () => import('@/views/modules/otras_obligaciones/GAdeudos_OpcMult_RA.vue') },
    { path: '/otras-obligaciones/gfacturacion', name: 'otras-obligaciones-gfacturacion', component: () => import('@/views/modules/otras_obligaciones/GFacturacion.vue') },
    { path: '/otras-obligaciones/grep-padron', name: 'otras-obligaciones-grep-padron', component: () => import('@/views/modules/otras_obligaciones/GRep_Padron.vue') },
    { path: '/otras-obligaciones/rnuevos', name: 'otras-obligaciones-rnuevos', component: () => import('@/views/modules/otras_obligaciones/RNuevos.vue') },
    { path: '/otras-obligaciones/rconsulta', name: 'otras-obligaciones-rconsulta', component: () => import('@/views/modules/otras_obligaciones/RConsulta.vue') },
    { path: '/otras-obligaciones/ractualiza', name: 'otras-obligaciones-ractualiza', component: () => import('@/views/modules/otras_obligaciones/RActualiza.vue') },
    { path: '/otras-obligaciones/rbaja', name: 'otras-obligaciones-rbaja', component: () => import('@/views/modules/otras_obligaciones/RBaja.vue') },
    { path: '/otras-obligaciones/radeudos', name: 'otras-obligaciones-radeudos', component: () => import('@/views/modules/otras_obligaciones/RAdeudos.vue') },
    { path: '/otras-obligaciones/radeudos-opc-mult', name: 'otras-obligaciones-radeudos-opc-mult', component: () => import('@/views/modules/otras_obligaciones/RAdeudos_OpcMult.vue') },
    { path: '/otras-obligaciones/rfacturacion', name: 'otras-obligaciones-rfacturacion', component: () => import('@/views/modules/otras_obligaciones/RFacturacion.vue') },
    { path: '/otras-obligaciones/rpagados', name: 'otras-obligaciones-rpagados', component: () => import('@/views/modules/otras_obligaciones/RPagados.vue') },
    { path: '/otras-obligaciones/rrep-padron', name: 'otras-obligaciones-rrep-padron', component: () => import('@/views/modules/otras_obligaciones/RRep_Padron.vue') },
    { path: '/otras-obligaciones/rubros', name: 'otras-obligaciones-rubros', component: () => import('@/views/modules/otras_obligaciones/Rubros.vue') },
    { path: '/otras-obligaciones/etiquetas', name: 'otras-obligaciones-etiquetas', component: () => import('@/views/modules/otras_obligaciones/Etiquetas.vue') },
    { path: '/otras-obligaciones/aux-rep', name: 'otras-obligaciones-aux-rep', component: () => import('@/views/modules/otras_obligaciones/AuxRep.vue') },
    { path: '/otras-obligaciones/carga-cartera', name: 'otras-obligaciones-carga-cartera', component: () => import('@/views/modules/otras_obligaciones/CargaCartera.vue') },
    { path: '/otras-obligaciones/carga-valores', name: 'otras-obligaciones-carga-valores', component: () => import('@/views/modules/otras_obligaciones/CargaValores.vue') },
    { path: '/otras-obligaciones/apremios', name: 'otras-obligaciones-apremios', component: () => import('@/views/modules/otras_obligaciones/Apremios.vue') }
  ]
})

export default router
