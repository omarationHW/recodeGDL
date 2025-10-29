<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Consulta Datos Energia</h1>
        <p>Mercados - Gestión de Energía</p>
      </div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <div class="consulta-datos-energia">
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
              <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
              <li class="breadcrumb-item active" aria-current="page">Consulta Datos de Energía</li>
            </ol>
          </nav>
          <h2>Consulta Datos de Energía</h2>
          <form @submit.prevent="buscar">
            <div class="form-group">
              <label class="municipal-form-label">ID Local</label>
              <div class="col-sm-4">
                <input v-model="id_local" type="number" class="municipal-form-control" required />
              </div>
              <div class="col-sm-2">
                <button class="btn-municipal-primary" type="submit">Buscar</button>
              </div>
            </div>
          </form>
          <div v-if="energia">
            <h4>Datos de Energía</h4>
            <table class="municipal-table">
              <tr class="row-hover"><th>Control Loc.</th><td>{{ energia.id_local }}</td></tr>
              <tr class="row-hover"><th>Clave Consumo</th><td>{{ energia.cve_consumo }} <span class="text-muted">{{ consumoDescripcion }}</span></td></tr>
              <tr class="row-hover"><th>Adicionales</th><td>{{ energia.local_adicional }}</td></tr>
              <tr class="row-hover"><th>Cantidad</th><td>{{ energia.cantidad }}</td></tr>
              <tr class="row-hover"><th>Vigencia</th><td>{{ energia.vigencia }} <span class="text-muted">{{ vigenciaDescripcion }}</span></td></tr>
              <tr class="row-hover"><th>Fecha Alta</th><td>{{ energia.fecha_alta }}</td></tr>
              <tr class="row-hover"><th>Fecha Baja</th><td>{{ energia.fecha_baja }}</td></tr>
              <tr class="row-hover"><th>Actualización</th><td>{{ energia.fecha_modificacion }}</td></tr>
              <tr class="row-hover"><th>Usuario</th><td>{{ energia.usuario }}</td></tr>
            </table>
            <div class="row">
              <div class="col-md-6">
                <h5>Requerimientos</h5>
                <table class="municipal-table">
                  <thead class="municipal-table-header">
                    <tr class="row-hover">
                      <th>Folio</th><th>Emisión</th><th>Vigencia</th><th>Diligencia</th><th>Practicado</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="req in requerimientos" :key="req.folio" class="row-hover">
                      <td>{{ req.folio }}</td>
                      <td>{{ req.fecha_emision }}</td>
                      <td>{{ req.vigencia }}</td>
                      <td>{{ req.diligencia }}</td>
                      <td>{{ req.clave_practicado }}</td>
                    </tr>
                    <tr v-if="!requerimientos.length" class="row-hover"><td colspan="5" class="text-center">Sin requerimientos</td></tr>
                  </tbody>
                </table>
              </div>
              <div class="col-md-6">
                <h5>Adeudos por Mes</h5>
                <table class="municipal-table">
                  <thead class="municipal-table-header">
                    <tr class="row-hover">
                      <th>Año</th><th>Mes</th><th>Adeudo</th><th>Recargos</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="ad in adeudos" :key="ad.axo + '-' + ad.periodo" class="row-hover">
                      <td>{{ ad.axo }}</td>
                      <td>{{ ad.periodo }}</td>
                      <td>{{ ad.importe | currency }}</td>
                      <td>{{ ad.recargos | currency }}</td>
                    </tr>
                    <tr v-if="!adeudos.length" class="row-hover"><td colspan="4" class="text-center">Sin adeudos</td></tr>
                  </tbody>
                </table>
              </div>
            </div>
            <div class="row mt-3">
              <div class="col-md-3">
                <strong>Adeudo:</strong> {{ resumen.adeudos | currency }}
              </div>
              <div class="col-md-3">
                <strong>Recargos:</strong> {{ resumen.recargos | currency }}
              </div>
              <div class="col-md-3">
                <strong>Multas:</strong> {{ resumen.multas | currency }}
              </div>
              <div class="col-md-3">
                <strong>Gastos:</strong> {{ resumen.gastos | currency }}
              </div>
            </div>
            <div class="row mt-2">
              <div class="col-md-12">
                <strong>Total Global:</strong> {{ resumen.total | currency }}
              </div>
            </div>
            <div class="row mt-3">
              <div class="col-md-12">
                <button class="btn btn-outline-secondary mr-2" @click="verPagos">Ver Pagos</button>
                <button class="btn btn-outline-info mr-2" @click="verCondonaciones">Ver Condonaciones</button>
                <button class="btn btn-outline-success" @click="imprimirCaratula">Imprimir Carátula</button>
              </div>
            </div>
            <div v-if="pagos.length" class="mt-4">
              <h5>Pagos de Energía</h5>
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr class="row-hover">
                    <th>Año</th><th>Mes</th><th>Fecha Pago</th><th>Importe</th><th>Usuario</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="p in pagos" :key="p.id_pago_energia" class="row-hover">
                    <td>{{ p.axo }}</td>
                    <td>{{ p.periodo }}</td>
                    <td>{{ p.fecha_pago }}</td>
                    <td>{{ p.importe_pago | currency }}</td>
                    <td>{{ p.usuario }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div v-if="condonaciones.length" class="mt-4">
              <h5>Condonaciones de Energía</h5>
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr class="row-hover">
                    <th>Año</th><th>Mes</th><th>Importe</th><th>Observación</th><th>Usuario</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="c in condonaciones" :key="c.id_cancelacion" class="row-hover">
                    <td>{{ c.axo }}</td>
                    <td>{{ c.periodo }}</td>
                    <td>{{ c.importe | currency }}</td>
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
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'ConsultaDatosEnergia'"
      :moduleName="'mercados'"
      @close="closeDocumentation"
    />
  </div>
  <!-- /module-view -->
</template>

<script>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

export default {
  components: {
    DocumentationModal
  },
  name: 'ConsultaDatosEnergia',
  data() {
    return {
      id_local: '',
      energia: null,
      requerimientos: [],
      adeudos: [],
      resumen: { adeudos: 0, recargos: 0, multas: 0, gastos: 0, total: 0,
      showDocumentation: false,
      toast: {
        show: false,
        type: 'info',
        message: ''
      }},
      pagos: [],
      condonaciones: [],
      error: ''
    };
  },
  computed: {
    consumoDescripcion() {
      if (!this.energia) return '';
      return this.energia.cve_consumo === 'F' ? 'Precio Fijo / Servicio Normal' :
             this.energia.cve_consumo === 'K' ? 'Precio Kilowhatts / Servicio Medido' : '';
    },
    vigenciaDescripcion() {
      if (!this.energia) return '';
      if (this.energia.vigencia === 'A' || !this.energia.vigencia) return 'VIGENTE';
      if (this.energia.vigencia === 'E') return 'VIGENTE / PARA EMISION';
      if (this.energia.vigencia === 'B') return 'BAJA';
      return '';
    }
  },
  methods: {
    openDocumentation() {
      this.showDocumentation = true;
    },
    closeDocumentation() {
      this.showDocumentation = false;
    },
    showToast(type, message) {
      this.toast = { show: true, type, message };
      setTimeout(() => this.hideToast(), 3000);
    },
    hideToast() {
      this.toast.show = false;
    },
    getToastIcon(type) {
      const icons = {
        success: 'check-circle',
        error: 'exclamation-circle',
        warning: 'exclamation-triangle',
        info: 'info-circle'
      };
      return icons[type] || 'info-circle';
    },
    async buscar() {
      this.error = '';
      this.energia = null;
      this.requerimientos = [];
      this.adeudos = [];
      this.resumen = { adeudos: 0, recargos: 0, multas: 0, gastos: 0, total: 0 };
      this.pagos = [];
      this.condonaciones = [];
      try {
        // 1. Obtener datos de energía
        let res = await this.api('getEnergiaByLocal', { id_local: this.id_local });
        if (!res.success || !res.data.length) {
          this.error = 'No se encontró información de energía para el local.';
          return;
        }
        this.energia = res.data[0];
        // 2. Requerimientos
        res = await this.api('getRequerimientosEnergia', { id_local: this.id_local });
        this.requerimientos = res.data || [];
        // 3. Adeudos
        res = await this.api('getAdeudosEnergia', { id_local: this.id_local });
        this.adeudos = res.data || [];
        // 4. Calcular resumen
        let adeudos = 0, recargos = 0, multas = 0, gastos = 0;
        for (let ad of this.adeudos) {
          adeudos += Number(ad.importe);
          recargos += Number(ad.recargos);
        }
        for (let req of this.requerimientos) {
          multas += Number(req.importe_multa);
          gastos += Number(req.importe_gastos);
        }
        this.resumen = {
          adeudos,
          recargos,
          multas,
          gastos,
          total: adeudos + recargos + multas + gastos
        };
      } catch (e) {
        this.error = e.message || 'Error de comunicación con el servidor';
      }
    },
    async verPagos() {
      if (!this.energia) return;
      let res = await this.api('getPagosEnergia', { id_energia: this.energia.id_energia });
      this.pagos = res.data || [];
    },
    async verCondonaciones() {
      if (!this.energia) return;
      let res = await this.api('getCondonacionesEnergia', { id_energia: this.energia.id_energia });
      this.condonaciones = res.data || [];
    },
    imprimirCaratula() {
      window.open(`/reportes/caratula-energia/${this.id_local}`, '_blank');
    },
    async api(action, params) {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action, params } })
      });
      const json = await res.json();
      return json.eResponse;
    }
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') return val;
      return '$' + val.toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
};
</script>


<style scoped>
/* Los estilos municipales se heredan de las clases globales */
/* Estilos específicos del componente si son necesarios */
</style>
