<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="store-alt" />
      </div>
      <div class="module-view-info">
        <h1>Carga de Pagos por Locales</h1>
        <p>Mercados - Registro de Pagos de Renta por Local</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button></div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card mb-3">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Datos del Local
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="row">
            <div class="col-md-3 mb-3">
              <label class="municipal-form-label">Recaudadora *</label>
              <select class="municipal-form-control" v-model="form.oficina" @change="onOficinaChange"
                :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
            <div class="col-md-3 mb-3">
              <label class="municipal-form-label">Mercado *</label>
              <select class="municipal-form-control" v-model="form.mercado" @change="onMercadoChange"
                :disabled="loading || !form.oficina">
                <option value="">Seleccione...</option>
                <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                  {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                </option>
              </select>
            </div>
            <div class="col-md-2 mb-3">
              <label class="municipal-form-label">Categoría</label>
              <input type="text" class="municipal-form-control" v-model="form.categoria" disabled />
            </div>
            <div class="col-md-2 mb-3">
              <label class="municipal-form-label">Sección *</label>
              <select class="municipal-form-control" v-model="form.seccion" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="sec in secciones" :key="sec.seccion" :value="sec.seccion">
                  {{ sec.seccion }}
                </option>
              </select>
            </div>
            <div class="col-md-2 mb-3">
              <label class="municipal-form-label">Local *</label>
              <input type="number" class="municipal-form-control" v-model.number="form.local" :disabled="loading"
                min="1" />
            </div>
          </div>
          <div class="d-flex justify-content-end">
            <button class="btn-municipal-primary" @click="buscarAdeudos" :disabled="!puedesBuscar || loading">
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
            Adeudos del Local
            <span class="badge bg-primary ms-2">{{ adeudos.length }}</span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table table-sm">
              <thead>
                <tr>
                  <th>Control</th>
                  <th>Rec</th>
                  <th>Merc</th>
                  <th>Cat</th>
                  <th>Sec</th>
                  <th>Local</th>
                  <th>Letra</th>
                  <th>Bloque</th>
                  <th>Año</th>
                  <th>Mes</th>
                  <th>Renta</th>
                  <th>Partida</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in adeudos" :key="`${row.id_local}-${row.axo}-${row.periodo}`">
                  <td>{{ row.id_local }}</td>
                  <td>{{ row.oficina }}</td>
                  <td>{{ row.num_mercado }}</td>
                  <td>{{ row.categoria }}</td>
                  <td>{{ row.seccion }}</td>
                  <td>{{ row.local }}</td>
                  <td>{{ row.letra_local }}</td>
                  <td>{{ row.bloque }}</td>
                  <td>{{ row.axo }}</td>
                  <td>{{ row.periodo }}</td>
                  <td>{{ formatCurrency(row.importe) }}</td>
                  <td>
                    <input type="text" class="municipal-form-control" v-model="row.partida" placeholder="Partida"
                      maxlength="20" style="width: 80px; height: 32px; font-size: 0.875rem;" />
                  </td>
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
              <input type="date" class="municipal-form-control" v-model="formPago.fecha_pago" :disabled="loading" />
            </div>
            <div class="col-md-3 mb-3">
              <label class="municipal-form-label">Oficina Pago *</label>
              <select class="municipal-form-control" v-model="formPago.oficina_pago" @change="onOficinaPagoChange"
                :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
            <div class="col-md-3 mb-3">
              <label class="municipal-form-label">Caja *</label>
              <select class="municipal-form-control" v-model="formPago.caja_pago"
                :disabled="loading || !formPago.oficina_pago">
                <option value="">Seleccione...</option>
                <option v-for="caja in cajas" :key="caja.caja" :value="caja.caja">
                  {{ caja.caja }}
                </option>
              </select>
            </div>
            <div class="col-md-3 mb-3">
              <label class="municipal-form-label">Operación *</label>
              <input type="number" class="municipal-form-control" v-model.number="formPago.operacion_pago"
                :disabled="loading" min="1" />
            </div>
          </div>

          <div class="d-flex justify-content-end gap-2">
            <button class="btn-municipal-primary" @click="grabarPagos" :disabled="!hayPagosValidos || loading">
              <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
              <font-awesome-icon icon="save" v-if="!loading" />
              Grabar Pagos
            </button>
            <button class="btn-municipal-secondary" @click="limpiar" :disabled="loading">
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
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
  faStoreAlt, faSearch, faList, faSave, faTimes,
  faQuestionCircle, faEraser, faInbox, faCreditCard
} from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { useGlobalLoading } from '@/composables/useGlobalLoading';

library.add(
  faStoreAlt, faSearch, faList, faSave, faTimes,
  faQuestionCircle, faEraser, faInbox, faCreditCard
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
  operacion_pago: ''
});

// Computed
const puedesBuscar = computed(() => {
  return form.value.oficina && form.value.mercado && form.value.seccion && form.value.local;
});

const hayPagosValidos = computed(() => {
  return adeudos.value.some(a => a.partida && a.partida.trim() !== '' && a.partida !== '0');
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
        Esquema: 'publico',
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
        Esquema: 'publico',
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
  form.value.categoria = '';
  mercados.value = [];

  if (!form.value.oficina) return;

  showLoading('Cargando mercados', 'Por favor espere');
  try {

    let oficinaParam = parseInt(form.value.oficina);
    let nivelUsuario = 1; // TODO: Obtener el nivel de usuario de la sesión
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_catalogo_mercados',
        Base: 'padron_licencias',
        Esquema: 'publico',
        Parametros: [
          { nombre: 'p_oficina', tipo: 'integer', valor: oficinaParam },
          { nombre: 'p_nivel_usuario', tipo: 'integer', valor: nivelUsuario }
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

// Cuando cambia el mercado
function onMercadoChange() {
  const mercadoSeleccionado = mercados.value.find(m => m.num_mercado_nvo == form.value.mercado);
  if (mercadoSeleccionado) {
    form.value.categoria = mercadoSeleccionado.categoria;
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
        Esquema: 'publico',
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

  showLoading('Buscando adeudos', 'Por favor espere');
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_adeudos_local',
        Base: 'mercados',
        Esquema: 'publico',
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
        partida: ''
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

// Grabar pagos
async function grabarPagos() {
  const pagosValidos = adeudos.value.filter(a =>
    a.partida && a.partida.trim() !== '' && a.partida !== '0'
  );

  if (pagosValidos.length === 0) {
    showToast('Debe capturar al menos una partida', 'warning');
    return;
  }

  if (!formPago.value.fecha_pago || !formPago.value.oficina_pago ||
    !formPago.value.caja_pago || !formPago.value.operacion_pago) {
    showToast('Complete todos los datos del pago', 'warning');
    return;
  }

  const result = await Swal.fire({
    title: '¿Grabar pagos?',
    text: `Se grabarán ${pagosValidos.length} pagos`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, grabar',
    cancelButtonText: 'Cancelar'
  });

  if (!result.isConfirmed) return;

  loading.value = true;

  showLoading('Grabando pagos', 'Por favor espere');
  try {
    const pagosJson = pagosValidos.map(a => ({
      id_local: a.id_local,
      axo: a.axo,
      periodo: a.periodo,
      importe: a.importe,
      partida: a.partida
    }));

    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_insert_pagos_mercado',
        Base: 'mercados',
        Esquema: 'publico',
        Parametros: [
          { Nombre: 'p_fecha_pago', Valor: formPago.value.fecha_pago },
          { Nombre: 'p_oficina', Valor: parseInt(formPago.value.oficina_pago) },
          { Nombre: 'p_caja', Valor: formPago.value.caja_pago },
          { Nombre: 'p_operacion', Valor: parseInt(formPago.value.operacion_pago) },
          { Nombre: 'p_usuario', Valor: 1 }, // TODO: Obtener de sesión
          { Nombre: 'p_mercado', Valor: parseInt(form.value.mercado) },
          { Nombre: 'p_categoria', Valor: parseInt(form.value.categoria) },
          { Nombre: 'p_seccion', Valor: form.value.seccion },
          { Nombre: 'p_pagos', Valor: JSON.stringify(pagosJson) }
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      showToast(`${pagosValidos.length} pagos grabados correctamente`, 'success');
      await buscarAdeudos();
    }
  } catch (error) {
    console.error('Error al grabar pagos:', error);
    showToast('Error al grabar pagos', 'error');
  } finally {
    loading.value = false;
    hideLoading();
  }
}

// Limpiar
function limpiar() {
  adeudos.value = [];
  formPago.value = {
    fecha_pago: new Date().toISOString().split('T')[0],
    oficina_pago: '',
    caja_pago: '',
    operacion_pago: ''
  };
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
    title: 'Ayuda - Carga de Pagos por Locales',
    html: `
      <div style="text-align: left;">
        <h6>Instrucciones:</h6>
        <ol>
          <li>Seleccione la recaudadora, mercado, sección y local</li>
          <li>Presione "Buscar Adeudos" para ver los adeudos pendientes</li>
          <li>Capture el número de partida para cada adeudo a pagar</li>
          <li>Complete los datos del pago (fecha, oficina, caja, operación)</li>
          <li>Presione "Grabar Pagos" para registrar</li>
        </ol>
        <p><strong>Nota:</strong> Solo se grabarán los adeudos que tengan partida capturada.</p>
      </div>
    `,
    icon: 'info',
    confirmButtonText: 'Entendido'
  });
}</script>
