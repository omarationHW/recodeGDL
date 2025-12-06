const fs = require('fs');
const path = require('path');

const archivos = [
  "_RptFacturaEmision.vue",
  "Acceso.vue",
  "AdeEnergiaGrl.vue",
  "AdeGlobalLocales.vue",
  "AdeudosEnergia.vue",
  "AdeudosLocales.vue",
  "AdeudosLocGrl.vue",
  "AltaPagos.vue",
  "AltaPagosEnergia.vue",
  "AutCargaPagos.vue",
  "AutCargaPagosMtto.vue",
  "CargaDiversosEsp.vue",
  "CargaPagEnergia.vue",
  "CargaPagEnergiaElec.vue",
  "CargaPagEspecial.vue",
  "CargaPagLocales.vue",
  "CargaPagMercado.vue",
  "CargaPagosTexto.vue",
  "CargaReqPagados.vue",
  "CargaTCultural.vue",
  "CatalogoMercados.vue",
  "CatalogoMntto.vue",
  "Categoria.vue",
  "CategoriaMntto.vue",
  "Condonacion.vue",
  "ConsCapturaEnergia.vue",
  "ConsCapturaFecha.vue",
  "ConsCapturaFechaEnergia.vue",
  "ConsCapturaMerc.vue",
  "ConsCondonacion.vue",
  "ConsCondonacionEnergia.vue",
  "ConsPagos.vue",
  "ConsPagosEnergia.vue",
  "ConsPagosLocales.vue",
  "ConsRequerimientos.vue",
  "ConsultaDatosEnergia.vue",
  "ConsultaDatosLocales.vue",
  "ConsultaGeneral.vue",
  "CuentaPublica.vue",
  "CuotasEnergia.vue",
  "CuotasEnergiaMntto.vue",
  "CuotasMdo.vue",
  "CuotasMdoMntto.vue",
  "CveCuota.vue",
  "CveCuotaMntto.vue",
  "CveDiferencias.vue",
  "CveDiferMntto.vue",
  "DatosConvenio.vue",
  "DatosIndividuales.vue",
  "DatosMovimientos.vue",
  "DatosRequerimientos.vue",
  "EmisionEnergia.vue",
  "EmisionLibertad.vue",
  "EmisionLocales.vue",
  "EnergiaModif.vue",
  "EnergiaMtto.vue",
  "Estadisticas.vue",
  "EstadPagosyAdeudos.vue",
  "FechaDescuento.vue",
  "FechasDescuentoMntto.vue",
  "Giros.vue",
  "index.vue",
  "IngresoCaptura.vue",
  "IngresoLib.vue",
  "ListadosLocales.vue",
  "LocalesModif.vue",
  "LocalesMtto.vue",
  "Menu.vue",
  "ModuloBD.vue",
  "PadronEnergia.vue",
  "PadronGlobal.vue",
  "PadronLocales.vue",
  "PagosDifIngresos.vue",
  "PagosEneCons.vue",
  "PagosIndividual.vue",
  "PagosLocGrl.vue",
  "PasoAdeudos.vue",
  "PasoEne.vue",
  "PasoMdos.vue",
  "Prescripcion.vue",
  "Recargos.vue",
  "RecargosMntto.vue",
  "RecaudadorasMercados.vue",
  "RepAdeudCond.vue",
  "ReporteGeneralMercados.vue",
  "RprtSalvadas.vue",
  "RptAdeEnergiaGrl.vue",
  "RptAdeudosAbastos1998.vue",
  "RptAdeudosAnteriores.vue",
  "RptAdeudosEnergia.vue",
  "RptAdeudosLocales.vue",
  "RptCaratulaDatos.vue",
  "RptCaratulaEnergia.vue",
  "RptCatalogoMerc.vue",
  "RptCuentaPublica.vue",
  "RptDesgloceAdePorimporte.vue",
  "RptEmisionEnergia.vue",
  "RptEmisionLaser.vue",
  "RptEmisionLocales.vue",
  "RptEmisionRbosAbastos.vue",
  "RptEstadisticaAdeudos.vue",
  "RptEstadPagosyAdeudos.vue",
  "RptFacturaEmision.vue",
  "RptFacturaEnergia.vue",
  "RptFacturaGLunes.vue",
  "RptFechasVencimiento.vue",
  "RptIngresos.vue",
  "RptIngresosEnergia.vue",
  "RptIngresoZonificado.vue",
  "RptLocalesGiro.vue",
  "RptMercados.vue",
  "RptMovimientos.vue",
  "RptPadronEnergia.vue",
  "RptPadronGlobal.vue",
  "RptPadronLocales.vue",
  "RptPagosAno.vue",
  "RptPagosCaja.vue",
  "RptPagosDetalle.vue",
  "RptPagosGrl.vue",
  "RptPagosLocales.vue",
  "RptResumenPagos.vue",
  "RptSaldosLocales.vue",
  "RptZonificacion.vue",
  "Secciones.vue",
  "SeccionesMntto.vue",
  "TrDocumentos.vue",
  "ZonasMercados.vue"
];

function categorizar(nombre) {
  const lower = nombre.toLowerCase();
  
  if (lower.startsWith('rpt') || lower.startsWith('_rpt')) return 'reportes';
  if (lower.startsWith('cons')) return 'consultas';
  if (lower.startsWith('carga')) return 'carga';
  if (lower.includes('mtto') || lower.includes('mntto')) return 'mantenimiento';
  if (lower.startsWith('ade') || lower.includes('adeudo')) return 'adeudos';
  if (lower.startsWith('pago') || lower.startsWith('paso')) return 'pagos';
  if (lower.startsWith('catalogo')) return 'catalogos';
  if (lower.startsWith('datos') || lower.startsWith('dif') || lower.includes('adeudos') || lower.includes('padron')) return 'datos';
  if (lower.startsWith('emision')) return 'emision';
  
  return 'otros';
}

function asignarPrioridad(nombre, categoria) {
  const lower = nombre.toLowerCase();
  
  // Alta prioridad: Funcionalidades críticas
  const altaPrioridad = [
    'consultageneral', 'datosindividuales', 'pagosindividual', 
    'adeudos', 'padron', 'emision', 'carga', 'altapagos',
    'catalogomercados', 'condonacion', 'prescripcion'
  ];
  
  // Media prioridad: Funcionalidades importantes
  const mediaPrioridad = [
    'cons', 'rpt', 'datos', 'reporte', 'estadist',
    'ingreso', 'cuota', 'energia', 'recargo', 'giro'
  ];
  
  for (const pattern of altaPrioridad) {
    if (lower.includes(pattern)) return 'alta';
  }
  
  for (const pattern of mediaPrioridad) {
    if (lower.includes(pattern)) return 'media';
  }
  
  return 'baja';
}

const porCategoria = {
  reportes: [],
  consultas: [],
  carga: [],
  mantenimiento: [],
  adeudos: [],
  pagos: [],
  catalogos: [],
  datos: [],
  emision: [],
  otros: []
};

const porPrioridad = {
  alta: [],
  media: [],
  baja: []
};

archivos.forEach(archivo => {
  const categoria = categorizar(archivo);
  const prioridad = asignarPrioridad(archivo, categoria);
  
  porCategoria[categoria].push(archivo);
  porPrioridad[prioridad].push({
    archivo,
    categoria
  });
});

// Ordenar alfabéticamente dentro de cada categoría
Object.keys(porCategoria).forEach(cat => {
  porCategoria[cat].sort();
});

// Ordenar alfabéticamente dentro de cada prioridad
['alta', 'media', 'baja'].forEach(pri => {
  porPrioridad[pri].sort((a, b) => a.archivo.localeCompare(b.archivo));
});

const resultado = {
  total: archivos.length,
  fecha_generacion: new Date().toISOString(),
  por_categoria: porCategoria,
  prioridad_alta: porPrioridad.alta,
  prioridad_media: porPrioridad.media,
  prioridad_baja: porPrioridad.baja,
  resumen_categorias: {
    reportes: porCategoria.reportes.length,
    consultas: porCategoria.consultas.length,
    carga: porCategoria.carga.length,
    mantenimiento: porCategoria.mantenimiento.length,
    adeudos: porCategoria.adeudos.length,
    pagos: porCategoria.pagos.length,
    catalogos: porCategoria.catalogos.length,
    datos: porCategoria.datos.length,
    emision: porCategoria.emision.length,
    otros: porCategoria.otros.length
  },
  resumen_prioridades: {
    alta: porPrioridad.alta.length,
    media: porPrioridad.media.length,
    baja: porPrioridad.baja.length
  }
};

console.log(JSON.stringify(resultado, null, 2));
