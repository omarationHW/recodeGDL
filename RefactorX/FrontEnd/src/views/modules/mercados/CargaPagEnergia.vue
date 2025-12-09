<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="bolt" />
      </div>
      <div class="module-view-info">
        <h1>Carga de Pagos de Energía Eléctrica</h1>
        <p>Mercados - Registro de Pagos por Consumo de Energía</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-purple"
          @click="mostrarAyuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
        <button
          class="btn-municipal-danger"
          @click="cerrar"
        >
          <font-awesome-icon icon="times" />
          Cerrar
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card mb-3">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Búsqueda de Local
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="row">
            <div class="col-md-4 mb-3">
              <label class="municipal-form-label">Recaudadora *</label>
              <select
                class="municipal-form-control"
                v-model="form.oficina"
                @change="onOficinaChange"
                :disabled="loading"
              >
                <option value="">Seleccione...</option>
                <option
                  v-for="rec in recaudadoras"
                  :key="rec.id_rec"
                  :value="rec.id_rec"
                >
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
            <div class="col-md-2 mb-3">
              <label class="municipal-form-label">Mercado *</label>
              <select
                class="municipal-form-control"
                v-model="form.mercado"
                :disabled="loading || !form.oficina"
              >
                <option value="">Seleccione...</option>
                <option
                  v-for="merc in mercados"
                  :key="merc.num_mercado_nvo"
                  :value="merc.num_mercado_nvo"
                >
                  {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                </option>
              </select>
            </div>
            <div class="col-md-2 mb-3">
              <label class="municipal-form-label">Categoría</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="form.categoria"
                disabled
              />
            </div>
            <div class="col-md-2 mb-3">
              <label class="municipal-form-label">Sección *</label>
              <select
                class="municipal-form-control"
                v-model="form.seccion"
                :disabled="loading"
              >
                <option value="">Seleccione...</option>
                <option
                  v-for="sec in secciones"
                  :key="sec.seccion"
                  :value="sec.seccion"
                >
                  {{ sec.seccion }}
                </option>
              </select>
            </div>
            <div class="col-md-2 mb-3">
              <label class="municipal-form-label">Local *</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="form.local"
                :disabled="loading"
                min="1"
              />
            </div>
          </div>
          <div class="d-flex justify-content-end">
            <button
              class="btn-municipal-primary"
              @click="buscarAdeudos"
              :disabled="!puedesBuscar || loading"
            >
              <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
              <font-awesome-icon icon="search" v-if="!loading" />
              Buscar Adeudos
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de Adeudos -->
      <div v-if="adeudos.length > 0" class="municipal-card mb-3">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Adeudos Encontrados
            <span class="badge bg-primary ms-2">{{ adeudos.length }}</span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table table-sm">
              <thead>
                <tr>
                  <th>Sel</th>
                  <th>Control</th>
                  <th>Rec</th>
                  <th>Merc</th>
                  <th>Cat</th>
                  <th>Sec</th>
                  <th>Local</th>
                  <th>Letra</th>
                  <th>Bloque</th>
                  <th>Año</th>
                  <th>Per</th>
                  <th>Consumo</th>
                  <th>Kilowatts</th>
                  <th>Importe</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in adeudos" :key="row.id_adeudo_energia">
                  <td>
                    <input type="checkbox" v-model="row.selected" />
                  </td>
                  <td>{{ row.id_energia }}</td>
                  <td>{{ row.oficina }}</td>
                  <td>{{ row.num_mercado }}</td>
                  <td>{{ row.categoria }}</td>
                  <td>{{ row.seccion }}</td>
                  <td>{{ row.local }}</td>
                  <td>{{ row.letra_local }}</td>
                  <td>{{ row.bloque }}</td>
                  <td>{{ row.axo }}</td>
                  <td>{{ row.periodo }}</td>
                  <td>{{ row.cve_consumo }}</td>
                  <td>{{ row.cantidad }}</td>
                  <td>{{ formatCurrency(row.importe) }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Datos del Pago -->
          <div class="row mt-3">
            <div class="col-md-12">
              <h6 class="text-primary mb-3">
                <font-awesome-icon icon="credit-card" />
                Datos del Pago
              </h6>
            </div>
            <div class="col-md-3 mb-3">
              <label class="municipal-form-label">Fecha de Pago *</label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="formPago.fecha_pago"
                :disabled="loading"
              />
            </div>
            <div class="col-md-3 mb-3">
              <label class="municipal-form-label">Oficina Pago *</label>
              <select
                class="municipal-form-control"
                v-model="formPago.oficina_pago"
                @change="onOficinaPagoChange"
                :disabled="loading"
              >
                <option value="">Seleccione...</option>
                <option
                  v-for="rec in recaudadoras"
                  :key="rec.id_rec"
                  :value="rec.id_rec"
                >
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
            <div class="col-md-2 mb-3">
              <label class="municipal-form-label">Caja *</label>
              <select
                class="municipal-form-control"
                v-model="formPago.caja_pago"
                :disabled="loading || !formPago.oficina_pago"
              >
                <option value="">Seleccione...</option>
                <option
                  v-for="caja in cajas"
                  :key="caja.caja"
                  :value="caja.caja"
                >
                  {{ caja.caja }}
                </option>
              </select>
            </div>
            <div class="col-md-2 mb-3">
              <label class="municipal-form-label">Operación *</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="formPago.operacion_pago"
                :disabled="loading"
                min="1"
              />
            </div>
            <div class="col-md-2 mb-3">
              <label class="municipal-form-label">Folio</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formPago.folio"
                :disabled="loading"
                maxlength="20"
              />
            </div>
          </div>

          <div class="d-flex justify-content-end gap-2">
            <button
              class="btn-municipal-success"
              @click="cargarPagos"
              :disabled="!haySeleccionados || loading"
            >
              <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
              <font-awesome-icon icon="save" v-if="!loading" />
              Cargar Pagos
            </button>
            <button
              class="btn-municipal-secondary"
              @click="limpiarAdeudos"
              :disabled="loading"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Historial de Pagos -->
      <div v-if="pagos.length > 0" class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="history" />
            Pagos Realizados
            <span class="badge bg-success ms-2">{{ pagos.length }}</span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table table-sm">
              <thead>
                <tr>
                  <th>ID Pago</th>
                  <th>Año</th>
                  <th>Periodo</th>
                  <th>Fecha Pago</th>
                  <th>Oficina</th>
                  <th>Caja</th>
                  <th>Operación</th>
                  <th>Importe</th>
                  <th>Consumo</th>
                  <th>Kilowatts</th>
                  <th>Folio</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="pago in pagos" :key="pago.id_pago_energia">
                  <td>{{ pago.id_pago_energia }}</td>
                  <td>{{ pago.axo }}</td>
                  <td>{{ pago.periodo }}</td>
                  <td>{{ formatDate(pago.fecha_pago) }}</td>
                  <td>{{ pago.oficina_pago }}</td>
                  <td>{{ pago.caja_pago }}</td>
                  <td>{{ pago.operacion_pago }}</td>
                  <td>{{ formatCurrency(pago.importe_pago) }}</td>
                  <td>{{ pago.cve_consumo }}</td>
                  <td>{{ pago.cantidad }}</td>
                  <td>{{ pago.folio }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Sin resultados -->
      <div v-if="adeudos.length === 0 && !loading" class="municipal-card">
        <div class="municipal-card-body text-center py-4 text-muted">
          <font-awesome-icon icon="inbox" size="3x" class="mb-3" />
          <p>Seleccione los filtros y presione "Buscar Adeudos" para ver los resultados.</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import axios from 'axios';
import Swal from 'sweetalert2';
import { library } from '@fortawesome/fontawesome-svg-core';
import {
  faBolt, faSearch, faList, faSave, faTimes,
  faQuestionCircle, faEraser, faInbox, faCreditCard, faHistory
} from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { useGlobalLoading } from '@/composables/useGlobalLoading';

library.add(
  faBolt, faSearch, faList, faSave, faTimes,
  faQuestionCircle, faEraser, faInbox, faCreditCard, faHistory
);

const router = useRouter();
const { showLoading, hideLoading } = useGlobalLoading();

// Helper para mostrar toasts
const showToast = (icon, title) => {
  Swal.fire({
    toast: true,
    position: 'top-end',
    icon,
    title,
    showConfirmButton: false,
    timer: 3000,
    timerProgressBar: true
  });
};

// Estados
const loading = ref(false);
const recaudadoras = ref([]);
const mercados = ref([]);
const secciones = ref([]);
const cajas = ref([]);
const adeudos = ref([]);
const pagos = ref([]);

// Formulario de búsqueda
const form = ref({
  oficina: '',
  mercado: '',
  categoria: '',
  seccion: '',
  local: ''
});

// Formulario de pago
const formPago = ref({
  fecha_pago: new Date().toISOString().split('T')[0],
  oficina_pago: '',
  caja_pago: '',
  operacion_pago: '',
  folio: ''
});

// Computed
const puedesBuscar = computed(() => {
  return form.value.oficina && form.value.mercado && form.value.seccion && form.value.local;
});

const haySeleccionados = computed(() => {
  return adeudos.value.some(a => a.selected);
});

// Cargar datos iniciales
onMounted(() => {
  cargarRecaudadoras();
  cargarSecciones();
});

// Cargar recaudadoras
async function cargarRecaudadoras() {
  showLoading('Cargando recaudadoras', 'Por favor espere');
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'padron_licencias',
        Parametros: []
      }
    });

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result) {
      recaudadoras.value = response.data.eResponse.data.result;
    }
  } catch (error) {
    console.error('Error al cargar recaudadoras:', error);
    showToast('Error al cargar recaudadoras', 'error');
  } finally {
    hideLoading();
  }
}

// Cargar secciones
async function cargarSecciones() {
  showLoading('Cargando secciones', 'Por favor espere');
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_secciones',
        Base: 'padron_licencias',
        Parametros: []
      }
    });

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result) {
      secciones.value = response.data.eResponse.data.result;
    }
  } catch (error) {
    console.error('Error al cargar secciones:', error);
    showToast('Error al cargar secciones', 'error');
  } finally {
    hideLoading();
  }
}

// Cuando cambia la oficina
async function onOficinaChange() {
  form.value.mercado = '';
  mercados.value = [];

  if (!form.value.oficina) return;

  showLoading('Cargando mercados', 'Por favor espere');
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_catalogo_mercados',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_id_rec', Valor: parseInt(form.value.oficina) },
          { nombre: 'p_nivel_usuario', tipo: 'integer', valor: 1 }
        ]
      }
    });

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result) {
      mercados.value = response.data.eResponse.data.result;
    }
  } catch (error) {
    console.error('Error al cargar mercados:', error);
    showToast('Error al cargar mercados', 'error');
  } finally {
    hideLoading();
  }
}

// Cuando cambia la oficina de pago
async function onOficinaPagoChange() {
  formPago.value.caja_pago = '';
  cajas.value = [];

  if (!formPago.value.oficina_pago) return;

  showLoading('Cargando cajas', 'Por favor espere');
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_cajas',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(formPago.value.oficina_pago) }
        ]
      }
    });

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result) {
      cajas.value = response.data.eResponse.data.result;
    }
  } catch (error) {
    console.error('Error al cargar cajas:', error);
    showToast('Error al cargar cajas', 'error');
  } finally {
    hideLoading();
  }
}

// Buscar adeudos
async function buscarAdeudos() {
  if (!puedesBuscar.value) {
    showToast('Complete todos los campos requeridos', 'warning');
    return;
  }

  loading.value = true;
  adeudos.value = [];
  pagos.value = [];

  showLoading('Buscando adeudos de energía', 'Por favor espere');
  try {
    // Obtener la categoría del mercado seleccionado
    const mercadoSeleccionado = mercados.value.find(m => m.num_mercado_nvo == form.value.mercado);
    if (mercadoSeleccionado) {
      form.value.categoria = mercadoSeleccionado.categoria;
    }

    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_buscar_adeudos_energia',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(form.value.oficina) },
          { Nombre: 'p_mercado', Valor: parseInt(form.value.mercado) },
          { Nombre: 'p_categoria', Valor: parseInt(form.value.categoria) },
          { Nombre: 'p_seccion', Valor: form.value.seccion },
          { Nombre: 'p_local', Valor: parseInt(form.value.local) }
        ]
      }
    });

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result) {
      adeudos.value = response.data.eResponse.data.result.map(a => ({
        ...a,
        selected: false
      }));

      if (adeudos.value.length === 0) {
        showToast('No se encontraron adeudos para este local', 'info');
      } else {
        showToast(`Se encontraron ${adeudos.value.length} adeudos`, 'success');
      }
    } else {
      showToast('No se encontraron adeudos', 'info');
    }
  } catch (error) {
    console.error('Error al buscar adeudos:', error);
    showToast('Error al buscar adeudos', 'error');
  } finally {
    loading.value = false;
    hideLoading();
  }
}

// Cargar pagos
async function cargarPagos() {
  const seleccionados = adeudos.value.filter(a => a.selected);

  if (seleccionados.length === 0) {
    showToast('Seleccione al menos un adeudo para pagar', 'warning');
    return;
  }

  if (!formPago.value.fecha_pago || !formPago.value.oficina_pago ||
      !formPago.value.caja_pago || !formPago.value.operacion_pago) {
    showToast('Complete todos los datos del pago', 'warning');
    return;
  }

  const result = await Swal.fire({
    title: '¿Cargar pagos?',
    text: `Se cargarán ${seleccionados.length} pagos de energía`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, cargar',
    cancelButtonText: 'Cancelar'
  });

  if (!result.isConfirmed) return;

  loading.value = true;

  showLoading('Cargando pagos de energía', 'Por favor espere');
  try {
    let pagosExitosos = 0;

    for (const adeudo of seleccionados) {
      const response = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_cargar_pago_energia',
          Base: 'mercados',
          Parametros: [
            { Nombre: 'p_id_energia', Valor: adeudo.id_energia },
            { Nombre: 'p_axo', Valor: adeudo.axo },
            { Nombre: 'p_periodo', Valor: adeudo.periodo },
            { Nombre: 'p_fecha_pago', Valor: formPago.value.fecha_pago },
            { Nombre: 'p_oficina_pago', Valor: parseInt(formPago.value.oficina_pago) },
            { Nombre: 'p_caja_pago', Valor: formPago.value.caja_pago },
            { Nombre: 'p_operacion_pago', Valor: parseInt(formPago.value.operacion_pago) },
            { Nombre: 'p_importe', Valor: adeudo.importe },
            { Nombre: 'p_cve_consumo', Valor: adeudo.cve_consumo },
            { Nombre: 'p_cantidad', Valor: adeudo.cantidad },
            { Nombre: 'p_folio', Valor: formPago.value.folio || '' },
            { Nombre: 'p_id_usuario', Valor: 1 } // TODO: Obtener de sesión
          ]
        }
      });

      if (response.data?.eResponse?.success) {
        pagosExitosos++;
      }
    }

    if (pagosExitosos > 0) {
      showToast(`${pagosExitosos} pagos cargados correctamente`, 'success');

      // Consultar pagos realizados
      if (seleccionados.length > 0) {
        await consultarPagos(seleccionados[0].id_energia);
      }

      // Recargar adeudos
      await buscarAdeudos();
    }
  } catch (error) {
    console.error('Error al cargar pagos:', error);
    showToast('Error al cargar pagos', 'error');
  } finally {
    loading.value = false;
    hideLoading();
  }
}

// Consultar pagos
async function consultarPagos(idEnergia) {
  showLoading('Consultando pagos realizados', 'Por favor espere');
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_consultar_pagos_energia',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_id_energia', Valor: idEnergia }
        ]
      }
    });

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result) {
      pagos.value = response.data.eResponse.data.result;
    }
  } catch (error) {
    console.error('Error al consultar pagos:', error);
  } finally {
    hideLoading();
  }
}

// Limpiar adeudos
function limpiarAdeudos() {
  adeudos.value = [];
  pagos.value = [];
  formPago.value = {
    fecha_pago: new Date().toISOString().split('T')[0],
    oficina_pago: '',
    caja_pago: '',
    operacion_pago: '',
    folio: ''
  };
}

// Formato de fecha
function formatDate(dateStr) {
  if (!dateStr) return '';
  const date = new Date(dateStr);
  return date.toLocaleDateString('es-MX');
}

// Formato de moneda
function formatCurrency(value) {
  if (!value && value !== 0) return '$0.00';
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value);
}

// Mostrar ayuda
function mostrarAyuda() {
  Swal.fire({
    title: 'Ayuda - Carga de Pagos de Energía',
    html: `
      <div style="text-align: left;">
        <h6>Instrucciones:</h6>
        <ol>
          <li>Seleccione la recaudadora, mercado, sección y local</li>
          <li>Presione "Buscar Adeudos" para ver los consumos pendientes</li>
          <li>Marque los adeudos que desea pagar con la casilla de selección</li>
          <li>Complete los datos del pago (fecha, oficina, caja, operación)</li>
          <li>Presione "Cargar Pagos" para registrar los pagos seleccionados</li>
        </ol>
        <p><strong>Nota:</strong> Los adeudos pagados se eliminarán automáticamente del listado.</p>
      </div>
    `,
    icon: 'info',
    confirmButtonText: 'Entendido'
  });
}

// Cerrar
function cerrar() {
  router.push('/');
}
</script>
