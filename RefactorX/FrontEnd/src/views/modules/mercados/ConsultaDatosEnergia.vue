<template>
  <div class="container-fluid py-4">
    <div class="municipal-card" style="min-height: 350px;">
      <div class="municipal-card-header">
        <h5 class="mb-0">Consulta Datos de Energía</h5>
      </div>
      <div class="municipal-card-body">
        <!-- Búsqueda -->
        <div class="row g-3 mb-4">
          <div class="col-md-3">
            <label class="form-label">ID Local</label>
            <input v-model="id_local" type="number" class="form-control" @keyup.enter="buscar" />
          </div>
          <div class="col-md-3 d-flex align-items-end">
            <button class="btn btn-municipal-primary" @click="buscar" :disabled="loading">
              <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
              Buscar
            </button>
          </div>
        </div>

        <!-- Datos de energía -->
        <div v-if="energia">
          <div class="row mb-4">
            <div class="col-md-6">
              <table class="table table-sm table-bordered">
                <tr><th width="40%">Control Loc.</th><td>{{ energia.id_local }}</td></tr>
                <tr><th>Clave Consumo</th><td>{{ energia.cve_consumo }} <small class="text-muted">{{ consumoDescripcion }}</small></td></tr>
                <tr><th>Adicionales</th><td>{{ energia.local_adicional || '-' }}</td></tr>
                <tr><th>Cantidad</th><td>{{ energia.cantidad }}</td></tr>
                <tr>
                  <th>Vigencia</th>
                  <td>
                    <span :class="energia.vigencia === 'A' ? 'badge bg-success' : 'badge bg-secondary'">
                      {{ vigenciaDescripcion }}
                    </span>
                  </td>
                </tr>
                <tr><th>Fecha Alta</th><td>{{ formatDate(energia.fecha_alta) }}</td></tr>
                <tr><th>Fecha Baja</th><td>{{ formatDate(energia.fecha_baja) || '-' }}</td></tr>
                <tr><th>Actualización</th><td>{{ formatDate(energia.fecha_modificacion) }}</td></tr>
                <tr><th>Usuario</th><td>{{ energia.usuario || '-' }}</td></tr>
              </table>
            </div>
            <div class="col-md-6">
              <h6>Adeudos por Mes</h6>
              <div class="table-responsive" style="max-height: 250px; overflow-y: auto;">
                <table class="table table-sm table-striped municipal-table">
                  <thead class="sticky-top bg-light">
                    <tr>
                      <th>Año</th>
                      <th>Mes</th>
                      <th>Adeudo</th>
                      <th>Recargos</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="ad in adeudos" :key="`${ad.axo}-${ad.periodo}`">
                      <td>{{ ad.axo }}</td>
                      <td>{{ ad.periodo }}</td>
                      <td>{{ formatCurrency(ad.importe) }}</td>
                      <td>{{ formatCurrency(ad.recargos) }}</td>
                    </tr>
                    <tr v-if="!adeudos.length">
                      <td colspan="4" class="text-center text-muted">Sin adeudos</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- Resumen -->
          <div class="row mb-3">
            <div class="col-md-3"><strong>Adeudo:</strong> {{ formatCurrency(resumen.adeudos) }}</div>
            <div class="col-md-3"><strong>Recargos:</strong> {{ formatCurrency(resumen.recargos) }}</div>
            <div class="col-md-3"><strong>Total:</strong> {{ formatCurrency(resumen.total) }}</div>
          </div>

          <!-- Botones -->
          <div class="mb-4">
            <button class="btn btn-outline-primary btn-sm me-2" @click="verPagos">Ver Pagos</button>
            <button class="btn btn-outline-info btn-sm" @click="verCondonaciones">Ver Condonaciones</button>
          </div>

          <!-- Pagos -->
          <div v-if="pagos.length" class="mb-4">
            <h6>Pagos de Energía</h6>
            <table class="table table-sm table-bordered municipal-table">
              <thead>
                <tr>
                  <th>Año</th>
                  <th>Mes</th>
                  <th>Fecha Pago</th>
                  <th>Importe</th>
                  <th>Usuario</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="p in pagos" :key="p.id_pago_energia">
                  <td>{{ p.axo }}</td>
                  <td>{{ p.periodo }}</td>
                  <td>{{ formatDate(p.fecha_pago) }}</td>
                  <td>{{ formatCurrency(p.importe_pago) }}</td>
                  <td>{{ p.usuario }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Condonaciones -->
          <div v-if="condonaciones.length">
            <h6>Condonaciones de Energía</h6>
            <table class="table table-sm table-bordered municipal-table">
              <thead>
                <tr>
                  <th>Año</th>
                  <th>Mes</th>
                  <th>Importe</th>
                  <th>Observación</th>
                  <th>Usuario</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="c in condonaciones" :key="c.id_cancelacion">
                  <td>{{ c.axo }}</td>
                  <td>{{ c.periodo }}</td>
                  <td>{{ formatCurrency(c.importe) }}</td>
                  <td>{{ c.observacion }}</td>
                  <td>{{ c.usuario }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import axios from 'axios';

const loading = ref(false);
const id_local = ref('');
const energia = ref(null);
const adeudos = ref([]);
const pagos = ref([]);
const condonaciones = ref([]);
const error = ref('');

const resumen = computed(() => {
  let total_adeudos = 0, total_recargos = 0;
  adeudos.value.forEach(ad => {
    total_adeudos += Number(ad.importe) || 0;
    total_recargos += Number(ad.recargos) || 0;
  });
  return {
    adeudos: total_adeudos,
    recargos: total_recargos,
    total: total_adeudos + total_recargos
  };
});

const consumoDescripcion = computed(() => {
  if (!energia.value) return '';
  return energia.value.cve_consumo === 'F' ? 'Precio Fijo' :
         energia.value.cve_consumo === 'K' ? 'Kilowatts' : '';
});

const vigenciaDescripcion = computed(() => {
  if (!energia.value) return '';
  if (energia.value.vigencia === 'A') return 'VIGENTE';
  if (energia.value.vigencia === 'E') return 'PARA EMISIÓN';
  if (energia.value.vigencia === 'B') return 'BAJA';
  return energia.value.vigencia;
});

const formatCurrency = (value) => {
  if (!value) return '$0.00';
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value);
};

const formatDate = (value) => {
  if (!value) return '';
  return new Date(value).toLocaleDateString('es-MX');
};

const buscar = async () => {
  if (!id_local.value) {
    alert('Ingrese el ID del local');
    return;
  }

  loading.value = true;
  error.value = '';
  energia.value = null;
  adeudos.value = [];
  pagos.value = [];
  condonaciones.value = [];

  try {
    // Obtener datos de energía
    const resEnergia = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_consulta_energia_get_by_local',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_id_local', Valor: parseInt(id_local.value) }
        ]
      }
    });

    if (resEnergia.data.eResponse?.success) {
      const result = resEnergia.data.eResponse.data.result || [];
      if (result.length > 0) {
        energia.value = result[0];

        // Obtener adeudos
        const resAdeudos = await axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_consulta_energia_get_adeudos',
            Base: 'padron_licencias',
            Parametros: [
              { Nombre: 'p_id_local', Valor: parseInt(id_local.value) }
            ]
          }
        });
        if (resAdeudos.data.eResponse?.success) {
          adeudos.value = resAdeudos.data.eResponse.data.result || [];
        }
      } else {
        error.value = 'No se encontró información de energía para este local';
      }
    }
  } catch (e) {
    error.value = 'Error de comunicación con el servidor';
    console.error(e);
  } finally {
    loading.value = false;
  }
};

const verPagos = async () => {
  if (!energia.value) return;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_consulta_energia_get_pagos',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_id_energia', Valor: energia.value.id_energia }
        ]
      }
    });
    if (response.data.eResponse?.success) {
      pagos.value = response.data.eResponse.data.result || [];
    }
  } catch (e) {
    console.error('Error al cargar pagos:', e);
  }
};

const verCondonaciones = async () => {
  if (!energia.value) return;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_consulta_energia_get_condonaciones',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_id_energia', Valor: energia.value.id_energia }
        ]
      }
    });
    if (response.data.eResponse?.success) {
      condonaciones.value = response.data.eResponse.data.result || [];
    }
  } catch (e) {
    console.error('Error al cargar condonaciones:', e);
  }
};
</script>
