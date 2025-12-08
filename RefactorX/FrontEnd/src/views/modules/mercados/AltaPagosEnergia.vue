<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="bolt" />
      </div>
      <div class="module-view-info">
        <h1>Alta de Pagos Energía</h1>
        <p>Mercados - Registro de Pagos de Energía Eléctrica</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
        <button class="btn-municipal-danger" @click="cerrar">
          <font-awesome-icon icon="times" />
          Cerrar
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Card de Datos del Mercado -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="building" />
            Datos del Mercado
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group col-md-6">
              <label class="municipal-form-label">Recaudadora *</label>
              <select class="municipal-form-control" v-model="filters.idRecaudadora" @change="onRecChange"
                :disabled="loading || panelPagoVisible">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>

            <div class="form-group col-md-6">
              <label class="municipal-form-label">Mercado *</label>
              <select class="municipal-form-control" v-model="filters.numMercado" @change="onMercadoChange"
                :disabled="!filters.idRecaudadora || loading || panelPagoVisible">
                <option value="">Seleccione...</option>
                <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                  {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                </option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group col-md-2">
              <label class="municipal-form-label">Sección *</label>
              <select class="municipal-form-control" v-model="filters.seccion" :disabled="loading || panelPagoVisible">
                <option value="">Seleccione...</option>
                <option v-for="sec in secciones" :key="sec.seccion" :value="sec.seccion">
                  {{ sec.seccion }} - {{ sec.descripcion }}
                </option>
              </select>
            </div>

            <div class="form-group col-md-2">
              <label class="municipal-form-label">Categoría *</label>
              <input type="number" class="municipal-form-control" v-model.number="filters.categoria" placeholder="0"
                :disabled="loading || panelPagoVisible" readonly />
            </div>

            <div class="form-group col-md-2">
              <label class="municipal-form-label">Local *</label>
              <input type="number" class="municipal-form-control" v-model.number="filters.local" placeholder="0"
                :disabled="loading || panelPagoVisible" />
            </div>

            <div class="form-group col-md-2">
              <label class="municipal-form-label">Letra</label>
              <input type="text" class="municipal-form-control" v-model="filters.letraLocal" placeholder=""
                maxlength="2" :disabled="loading || panelPagoVisible" />
            </div>

            <div class="form-group col-md-2">
              <label class="municipal-form-label">Bloque</label>
              <input type="text" class="municipal-form-control" v-model="filters.bloque" placeholder="" maxlength="5"
                :disabled="loading || panelPagoVisible" />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group col-md-2">
              <label class="municipal-form-label">Año *</label>
              <input type="number" class="municipal-form-control" v-model.number="pago.axo"
                :disabled="loading || panelPagoVisible" />
            </div>

            <div class="form-group col-md-2">
              <label class="municipal-form-label">Mes/Periodo *</label>
              <input type="number" class="municipal-form-control" v-model.number="pago.periodo"
                min="1" max="12" :disabled="loading || panelPagoVisible" />
            </div>

            <div class="form-group col-md-8 d-flex align-items-end">
              <button class="btn-municipal-primary" @click="buscarLocal"
                :disabled="loading || !validarBusqueda() || panelPagoVisible">
                <font-awesome-icon icon="search" />
                Buscar
              </button>
            </div>
          </div>

          <!-- Mensaje de error o información -->
          <div v-if="errorBusqueda" class="alert alert-warning mt-3">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ errorBusqueda }}
          </div>
        </div>
      </div>

      <!-- Card de Datos del Pago de Energía -->
      <div class="municipal-card mt-3" v-if="panelPagoVisible">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="bolt" />
            Datos del Pago de Energía Eléctrica
          </h5>
        </div>
        <div class="municipal-card-body">
          <!-- Información del Local -->
          <div class="alert alert-info mb-3">
            <div class="row">
              <div class="col-md-3">
                <strong>ID Local:</strong> {{ localEncontrado?.id_local }}
              </div>
              <div class="col-md-3">
                <strong>ID Energía:</strong> {{ localEncontrado?.id_energia }}
              </div>
              <div class="col-md-3">
                <strong>Cve Consumo:</strong> {{ localEncontrado?.cve_consumo }}
              </div>
              <div class="col-md-3">
                <strong>Cantidad:</strong> {{ localEncontrado?.cantidad }}
              </div>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group col-md-3">
              <label class="municipal-form-label">Fecha de Pago *</label>
              <input type="date" class="municipal-form-control" v-model="pago.fechaPago" :disabled="loading" />
            </div>

            <div class="form-group col-md-3">
              <label class="municipal-form-label">Oficina de Pago *</label>
              <select class="municipal-form-control" v-model="pago.oficinaPago" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>

            <div class="form-group col-md-3">
              <label class="municipal-form-label">Caja *</label>
              <select class="municipal-form-control" v-model="pago.cajaPago" :disabled="loading">
                <option value="">Seleccione...</option>
                <option value="01">01</option>
                <option value="02">02</option>
                <option value="03">03</option>
                <option value="04">04</option>
                <option value="05">05</option>
              </select>
            </div>

            <div class="form-group col-md-3">
              <label class="municipal-form-label">Operación *</label>
              <input type="number" class="municipal-form-control" v-model.number="pago.operacionPago"
                placeholder="Núm. Operación" :disabled="loading" />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group col-md-3">
              <label class="municipal-form-label">Importe Pagado *</label>
              <input type="number" class="municipal-form-control" v-model.number="pago.importePago" placeholder="0.00"
                step="0.01" :disabled="loading" />
            </div>

            <div class="form-group col-md-3">
              <label class="municipal-form-label">Consumo *</label>
              <select class="municipal-form-control" v-model="pago.cveConsumo" :disabled="loading">
                <option value="">Seleccione...</option>
                <option value="F">F - Kilowatts Fijo</option>
                <option value="K">K - Kilowatts Variable</option>
              </select>
            </div>

            <div class="form-group col-md-3">
              <label class="municipal-form-label">Cantidad</label>
              <input type="number" class="municipal-form-control" v-model.number="pago.cantidad" placeholder="0.00"
                step="0.01" :disabled="loading" />
            </div>

            <div class="form-group col-md-3">
              <label class="municipal-form-label">Folio/Partida *</label>
              <input type="text" class="municipal-form-control" v-model="pago.folio" placeholder="Folio" maxlength="20"
                :disabled="loading" />
            </div>
          </div>

          <div class="d-flex justify-content-end mt-3 gap-2">
            <button class="btn-municipal-success" @click="agregarPago"
              :disabled="loading || !validarPago() || pagoExistente">
              <font-awesome-icon icon="save" />
              Agregar
            </button>
            <button class="btn-municipal-warning" @click="modificarPago"
              :disabled="loading || !validarPago() || !pagoExistente">
              <font-awesome-icon icon="edit" />
              Modificar
            </button>
            <button class="btn-municipal-danger" @click="borrarPago"
              :disabled="loading || !pagoExistente">
              <font-awesome-icon icon="trash" />
              Borrar
            </button>
            <button class="btn-municipal-secondary" @click="cancelarPago" :disabled="loading">
              <font-awesome-icon icon="times" />
              Cancelar
            </button>
          </div>
        </div>
      </div>

      <!-- Card de Adeudos de Energía -->
      <div class="municipal-card mt-3" v-if="mostrarAdeudos && adeudos.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Adeudos de Energía del Local
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead>
                <tr>
                  <th>Año</th>
                  <th>Periodo</th>
                  <th>Consumo</th>
                  <th>Cantidad</th>
                  <th>Importe</th>
                  <th>Fecha Alta</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(adeudo, index) in adeudos" :key="index">
                  <td>{{ adeudo.axo }}</td>
                  <td>{{ adeudo.periodo }}</td>
                  <td>{{ adeudo.cve_consumo }}</td>
                  <td>{{ adeudo.cantidad }}</td>
                  <td>{{ formatMoneda(adeudo.importe) }}</td>
                  <td>{{ formatFecha(adeudo.fecha_alta) }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import axios from 'axios';
import { useToast } from 'vue-toastification';
import { useGlobalLoading } from '@/composables/useGlobalLoading';

const router = useRouter();
const toast = useToast();
const globalLoading = useGlobalLoading();

// Estados
const loading = ref(false); // Solo para deshabilitar campos durante operaciones
const recaudadoras = ref([]);
const mercados = ref([]);
const secciones = ref([]);
const localEncontrado = ref(null);
const errorBusqueda = ref('');
const mostrarAdeudos = ref(false);
const adeudos = ref([]);
const panelPagoVisible = ref(false);
const pagoExistente = ref(false);

// Filtros de búsqueda
const filters = ref({
  idRecaudadora: '',
  numMercado: '',
  seccion: '',
  categoria: null,
  local: null,
  letraLocal: '',
  bloque: ''
});

// Datos del pago
const pago = ref({
  axo: new Date().getFullYear(),
  periodo: new Date().getMonth() + 1,
  fechaPago: new Date().toISOString().split('T')[0],
  oficinaPago: '',
  cajaPago: '',
  operacionPago: null,
  importePago: 0,
  cveConsumo: '',
  cantidad: 0,
  folio: ''
});

// Cargar datos iniciales
onMounted(async () => {
  await Promise.all([
    fetchRecaudadoras(),
    fetchSecciones()
  ]);
});

// Fetch Recaudadoras
async function fetchRecaudadoras() {
  await globalLoading.withLoading(async () => {
    loading.value = true;
    try {
      const response = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_get_recaudadoras',
          Base: 'padron_licencias',
          Parametros: []
        }
      });

      if (response.data?.eResponse?.success) {
        recaudadoras.value = response.data.eResponse.data.result || [];
      }
    } catch (error) {
      toast.error('Error al cargar recaudadoras: ' + error.message);
      throw error;
    } finally {
      loading.value = false;
    }
  }, 'Cargando recaudadoras');
}

// Cambio de recaudadora
async function onRecChange() {
  mercados.value = [];
  filters.value.numMercado = '';
  filters.value.categoria = null;

  if (!filters.value.idRecaudadora) return;

  await globalLoading.withLoading(async () => {
    loading.value = true;
    try {
      const response = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_get_catalogo_mercados',
          Base: 'padron_licencias',
          Parametros: [
            { nombre: 'p_id_rec', tipo: 'int4', valor: parseInt(filters.value.idRecaudadora) },
            { nombre: 'p_nivel_usuario', tipo: 'integer', valor: 1 }
          ]
        }
      });

      if (response.data?.eResponse?.success) {
        mercados.value = response.data.eResponse.data.result || [];
      }
    } catch (error) {
      toast.error('Error al cargar mercados: ' + error.message);
      throw error;
    } finally {
      loading.value = false;
    }
  }, 'Cargando mercados');
}

// Cambio de mercado - actualiza categoría
function onMercadoChange() {
  if (filters.value.numMercado) {
    const mercado = mercados.value.find(m => m.num_mercado_nvo === parseInt(filters.value.numMercado));
    if (mercado) {
      filters.value.categoria = mercado.categoria;
    }
  } else {
    filters.value.categoria = null;
  }
}

// Fetch Secciones
async function fetchSecciones() {
  await globalLoading.withLoading(async () => {
    loading.value = true;
    try {
      const response = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_get_secciones',
          Base: 'padron_licencias',
          Parametros: []
        }
      });

      if (response.data?.eResponse?.success) {
        secciones.value = response.data.eResponse.data.result || [];
      }
    } catch (error) {
      toast.error('Error al cargar secciones: ' + error.message);
      throw error;
    } finally {
      loading.value = false;
    }
  }, 'Cargando secciones');
}

// Validar búsqueda
function validarBusqueda() {
  return filters.value.idRecaudadora &&
    filters.value.numMercado &&
    filters.value.seccion &&
    filters.value.local !== null &&
    pago.value.axo > 0 &&
    pago.value.periodo >= 1 && pago.value.periodo <= 12;
}

// Buscar Local
async function buscarLocal() {
  if (!validarBusqueda()) {
    toast.warning('Complete todos los campos obligatorios');
    return;
  }

  // Validar que el año no sea mayor al actual
  const anoActual = new Date().getFullYear();
  if (pago.value.axo > anoActual) {
    toast.warning('No puedes capturar un pago del próximo año');
    return;
  }

  await globalLoading.withLoading(async () => {
    loading.value = true;
    errorBusqueda.value = '';
    localEncontrado.value = null;
    panelPagoVisible.value = false;
    pagoExistente.value = false;

    try {
      // Buscar local y verificar si paga energía
      const response = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_alta_pagos_energia_buscar_local',
          Base: 'padron_licencias',
          Parametros: [
            { nombre: 'p_oficina', tipo: 'int4', valor: parseInt(filters.value.idRecaudadora) },
            { nombre: 'p_num_mercado', tipo: 'int4', valor: parseInt(filters.value.numMercado) },
            { nombre: 'p_categoria', tipo: 'int4', valor: parseInt(filters.value.categoria) },
            { nombre: 'p_seccion', tipo: 'text', valor: filters.value.seccion },
            { nombre: 'p_local', tipo: 'int4', valor: parseInt(filters.value.local) },
            { nombre: 'p_letra_local', tipo: 'text', valor: filters.value.letraLocal || '' },
            { nombre: 'p_bloque', tipo: 'text', valor: filters.value.bloque || '' }
          ]
        }
      });

      if (response.data?.eResponse?.success) {
        const result = response.data.eResponse.data.result;
        if (result && result.length > 0) {
          const local = result[0];

          if (!local.id_energia) {
            errorBusqueda.value = 'El Local Digitado no Paga Energía Eléctrica';
            toast.warning(errorBusqueda.value);
            return;
          }

          localEncontrado.value = local;

          // Establecer consumo por defecto del local
          pago.value.cveConsumo = local.cve_consumo || '';

          // Verificar si ya existe un pago para este periodo
          await verificarPagoExistente();

          // Cargar adeudos
          await cargarAdeudos();

          panelPagoVisible.value = true;
          toast.success('Local encontrado correctamente');
        } else {
          errorBusqueda.value = 'No Existe el Local Digitado';
          toast.warning(errorBusqueda.value);
        }
      }
    } catch (error) {
      errorBusqueda.value = 'Error al buscar el local';
      toast.error('Error al buscar local: ' + error.message);
      throw error;
    } finally {
      loading.value = false;
    }
  }, 'Buscando local');
}

// Verificar si existe pago (llamada interna, sin loading global)
async function verificarPagoExistente() {
  if (!localEncontrado.value?.id_energia) return;

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_alta_pagos_energia_consultar_pago',
        Base: 'padron_licencias',
        Parametros: [
          { nombre: 'p_id_energia', tipo: 'int4', valor: localEncontrado.value.id_energia },
          { nombre: 'p_axo', tipo: 'int4', valor: pago.value.axo },
          { nombre: 'p_periodo', tipo: 'int4', valor: pago.value.periodo }
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      const result = response.data.eResponse.data.result;
      if (result && result.length > 0) {
        // Cargar datos del pago existente
        const pagoData = result[0];
        pago.value.fechaPago = pagoData.fecha_pago?.split('T')[0] || pagoData.fecha_pago;
        pago.value.oficinaPago = pagoData.oficina_pago;
        pago.value.cajaPago = pagoData.caja_pago;
        pago.value.operacionPago = pagoData.operacion_pago;
        pago.value.importePago = pagoData.importe_pago;
        pago.value.cveConsumo = pagoData.cve_consumo;
        pago.value.cantidad = pagoData.cantidad;
        pago.value.folio = pagoData.folio;
        pagoExistente.value = true;
      } else {
        // Limpiar datos del pago y buscar en adeudos
        pago.value.fechaPago = new Date().toISOString().split('T')[0];
        pago.value.oficinaPago = '';
        pago.value.cajaPago = '';
        pago.value.operacionPago = null;
        pago.value.folio = '';
        pagoExistente.value = false;

        // Buscar importe en adeudos
        await buscarImporteEnAdeudos();
      }
    }
  } catch (error) {
    console.error('Error al verificar pago:', error);
  }
}

// Buscar importe en adeudos (llamada interna, sin loading global)
async function buscarImporteEnAdeudos() {
  if (!localEncontrado.value?.id_energia) return;

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_alta_pagos_energia_listar_adeudos',
        Base: 'padron_licencias',
        Parametros: [
          { nombre: 'p_id_energia', tipo: 'int4', valor: localEncontrado.value.id_energia }
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      const result = response.data.eResponse.data.result || [];
      const adeudo = result.find(a => a.axo === pago.value.axo && a.periodo === pago.value.periodo);
      if (adeudo) {
        pago.value.importePago = adeudo.importe;
        pago.value.cantidad = adeudo.cantidad;
      } else {
        pago.value.importePago = 0;
        pago.value.cantidad = 0;
      }
    }
  } catch (error) {
    console.error('Error al buscar importe en adeudos:', error);
  }
}

// Cargar adeudos del local (llamada interna, sin loading global)
async function cargarAdeudos() {
  if (!localEncontrado.value?.id_energia) return;

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_alta_pagos_energia_listar_adeudos',
        Base: 'padron_licencias',
        Parametros: [
          { nombre: 'p_id_energia', tipo: 'int4', valor: localEncontrado.value.id_energia }
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      adeudos.value = response.data.eResponse.data.result || [];
      mostrarAdeudos.value = true;
    }
  } catch (error) {
    console.error('Error al cargar adeudos:', error);
  }
}

// Validar datos del pago
function validarPago() {
  return localEncontrado.value?.id_energia &&
    pago.value.axo > 0 &&
    pago.value.periodo >= 1 && pago.value.periodo <= 12 &&
    pago.value.fechaPago &&
    pago.value.oficinaPago &&
    pago.value.cajaPago &&
    pago.value.operacionPago &&
    pago.value.importePago > 0 &&
    pago.value.cveConsumo &&
    pago.value.folio;
}

// Agregar pago
async function agregarPago() {
  if (!validarPago()) {
    toast.warning('Complete todos los campos del pago');
    return;
  }

  await globalLoading.withLoading(async () => {
    loading.value = true;
    try {
      const response = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_alta_pagos_energia_agregar',
          Base: 'padron_licencias',
          Parametros: [
            { nombre: 'p_id_energia', tipo: 'int4', valor: localEncontrado.value.id_energia },
            { nombre: 'p_axo', tipo: 'int4', valor: pago.value.axo },
            { nombre: 'p_periodo', tipo: 'int4', valor: pago.value.periodo },
            { nombre: 'p_fecha_pago', tipo: 'date', valor: pago.value.fechaPago },
            { nombre: 'p_oficina_pago', tipo: 'int4', valor: parseInt(pago.value.oficinaPago) },
            { nombre: 'p_caja_pago', tipo: 'text', valor: pago.value.cajaPago },
            { nombre: 'p_operacion_pago', tipo: 'int4', valor: pago.value.operacionPago },
            { nombre: 'p_importe_pago', tipo: 'numeric', valor: pago.value.importePago },
            { nombre: 'p_cve_consumo', tipo: 'text', valor: pago.value.cveConsumo },
            { nombre: 'p_cantidad', tipo: 'numeric', valor: pago.value.cantidad || 0 },
            { nombre: 'p_folio', tipo: 'text', valor: pago.value.folio },
            { nombre: 'p_id_usuario', tipo: 'int4', valor: 1 } // TODO: Obtener de sesión
          ]
        }
      });

      if (response.data?.eResponse?.success) {
        const result = response.data.eResponse.data.result;
        if (result && result[0]?.success) {
          toast.success(result[0].message || 'Pago agregado correctamente');
          cancelarPago();
        } else {
          toast.error(result[0]?.message || 'Error al agregar pago');
        }
      }
    } catch (error) {
      toast.error('Error al agregar pago: ' + error.message);
      throw error;
    } finally {
      loading.value = false;
    }
  }, 'Agregando pago');
}

// Modificar pago
async function modificarPago() {
  if (!validarPago()) {
    toast.warning('Complete todos los campos del pago');
    return;
  }

  await globalLoading.withLoading(async () => {
    loading.value = true;
    try {
      const response = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_alta_pagos_energia_modificar',
          Base: 'padron_licencias',
          Parametros: [
            { nombre: 'p_id_energia', tipo: 'int4', valor: localEncontrado.value.id_energia },
            { nombre: 'p_axo', tipo: 'int4', valor: pago.value.axo },
            { nombre: 'p_periodo', tipo: 'int4', valor: pago.value.periodo },
            { nombre: 'p_fecha_pago', tipo: 'date', valor: pago.value.fechaPago },
            { nombre: 'p_oficina_pago', tipo: 'int4', valor: parseInt(pago.value.oficinaPago) },
            { nombre: 'p_caja_pago', tipo: 'text', valor: pago.value.cajaPago },
            { nombre: 'p_operacion_pago', tipo: 'int4', valor: pago.value.operacionPago },
            { nombre: 'p_importe_pago', tipo: 'numeric', valor: pago.value.importePago },
            { nombre: 'p_cve_consumo', tipo: 'text', valor: pago.value.cveConsumo },
            { nombre: 'p_cantidad', tipo: 'numeric', valor: pago.value.cantidad || 0 },
            { nombre: 'p_folio', tipo: 'text', valor: pago.value.folio },
            { nombre: 'p_id_usuario', tipo: 'int4', valor: 1 } // TODO: Obtener de sesión
          ]
        }
      });

      if (response.data?.eResponse?.success) {
        const result = response.data.eResponse.data.result;
        if (result && result[0]?.success) {
          toast.success(result[0].message || 'Pago modificado correctamente');
          cancelarPago();
        } else {
          toast.error(result[0]?.message || 'Error al modificar pago');
        }
      }
    } catch (error) {
      toast.error('Error al modificar pago: ' + error.message);
      throw error;
    } finally {
      loading.value = false;
    }
  }, 'Modificando pago');
}

// Borrar pago
async function borrarPago() {
  if (!confirm('¿Está seguro de eliminar este pago?')) return;

  await globalLoading.withLoading(async () => {
    loading.value = true;
    try {
      const response = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_alta_pagos_energia_borrar',
          Base: 'padron_licencias',
          Parametros: [
            { nombre: 'p_id_energia', tipo: 'int4', valor: localEncontrado.value.id_energia },
            { nombre: 'p_axo', tipo: 'int4', valor: pago.value.axo },
            { nombre: 'p_periodo', tipo: 'int4', valor: pago.value.periodo },
            { nombre: 'p_id_usuario', tipo: 'int4', valor: 1 } // TODO: Obtener de sesión
          ]
        }
      });

      if (response.data?.eResponse?.success) {
        const result = response.data.eResponse.data.result;
        if (result && result[0]?.success) {
          toast.success(result[0].message || 'Pago eliminado correctamente');
          cancelarPago();
        } else {
          toast.error(result[0]?.message || 'Error al eliminar pago');
        }
      }
    } catch (error) {
      toast.error('Error al eliminar pago: ' + error.message);
      throw error;
    } finally {
      loading.value = false;
    }
  }, 'Eliminando pago');
}

// Cancelar edición
function cancelarPago() {
  panelPagoVisible.value = false;
  localEncontrado.value = null;
  errorBusqueda.value = '';
  mostrarAdeudos.value = false;
  adeudos.value = [];
  pagoExistente.value = false;

  // Limpiar filtros parcialmente
  filters.value.local = null;
  filters.value.letraLocal = '';
  filters.value.bloque = '';

  // Resetear pago
  pago.value = {
    axo: new Date().getFullYear(),
    periodo: new Date().getMonth() + 1,
    fechaPago: new Date().toISOString().split('T')[0],
    oficinaPago: '',
    cajaPago: '',
    operacionPago: null,
    importePago: 0,
    cveConsumo: '',
    cantidad: 0,
    folio: ''
  };
}

// Formato de moneda
function formatMoneda(valor) {
  if (!valor) return '$0.00';
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(valor);
}

// Formato de fecha
function formatFecha(fecha) {
  if (!fecha) return '-';
  return new Date(fecha).toLocaleDateString('es-MX');
}

// Mostrar ayuda
function mostrarAyuda() {
  toast.info('Ayuda: Seleccione la recaudadora, mercado, ingrese los datos del local y presione Buscar. Complete los datos del pago y presione Agregar o Modificar según corresponda.');
}

// Cerrar
function cerrar() {
  router.push('/');
}
</script>

<!-- Sin estilos scoped - Se usan clases municipales globales -->
<!-- Clases utilizadas: module-view, municipal-card, municipal-form-control, btn-municipal-*, gap-2 -->
