<template>
  <div class="pagos-cons-cont-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active">Consulta de Pagos por Contrato y Tipo de Aseo</li>
      </ol>
    </nav>
    <h2>Consulta de Pagos por Contrato y Tipo de Aseo</h2>
    <div class="card mb-3">
      <div class="card-body">
        <form @submit.prevent="buscarPagos">
          <div class="row g-2 align-items-end">
            <div class="col-md-3">
              <label for="contrato" class="form-label">No. Contrato</label>
              <input v-model="contrato" id="contrato" type="text" class="form-control" maxlength="10" required pattern="\\d+" />
            </div>
            <div class="col-md-4">
              <label for="tipoAseo" class="form-label">Tipo de Aseo</label>
              <select v-model="ctrolAseo" id="tipoAseo" class="form-select" required>
                <option v-for="ta in tipoAseoList" :key="ta.ctrol_aseo" :value="ta.ctrol_aseo">
                  {{ ta.ctrol_aseo.toString().padStart(3, '0') }} - {{ ta.tipo_aseo }} - {{ ta.descripcion }}
                </option>
              </select>
            </div>
            <div class="col-md-2">
              <button type="submit" class="btn btn-primary">Buscar</button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div v-if="pagos.length > 0" class="card mb-3">
      <div class="card-header d-flex justify-content-between align-items-center">
        <span>Pagos del Contrato</span>
        <button class="btn btn-outline-secondary btn-sm" @click="descargarEdoCuenta">
          <i class="bi bi-file-earmark-pdf"></i> Edo. de Cuenta
        </button>
      </div>
      <div class="card-body p-0">
        <table class="table table-striped table-hover mb-0">
          <thead>
            <tr>
              <th>Periodo</th>
              <th>Operación</th>
              <th>Exed.</th>
              <th>Importe</th>
              <th>Status</th>
              <th>Fecha Pago</th>
              <th>Ofna</th>
              <th>Caja</th>
              <th>Consec. Operación</th>
              <th>Folio Rcbo</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="p in pagos" :key="p.aso_mes_pago + '-' + p.ctrol_operacion">
              <td>{{ formatPeriodo(p.aso_mes_pago) }}</td>
              <td>{{ p.descripcion }}</td>
              <td>{{ p.exedencias }}</td>
              <td>{{ p.importe | currency }}</td>
              <td>{{ p.status_vigencia }}</td>
              <td>{{ formatFecha(p.fecha_hora_pago) }}</td>
              <td>{{ p.id_rec }}</td>
              <td>{{ p.caja }}</td>
              <td>{{ p.consec_operacion }}</td>
              <td>{{ p.folio_rcbo }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="loading" class="text-center my-4">
      <span class="spinner-border"></span> Cargando...
    </div>
  </div>
</template>

<script>
export default {
  name: 'PagosConsContPage',
  data() {
    return {
      contrato: '',
      ctrolAseo: '',
      tipoAseoList: [],
      pagos: [],
      controlContrato: null,
      error: '',
      loading: false
    };
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') return val;
      return val.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  },
  methods: {
    async cargarTipoAseo() {
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'getTipoAseo' })
        });
        const data = await res.json();
        if (data.success) {
          this.tipoAseoList = data.data;
          if (this.tipoAseoList.length > 0) {
            this.ctrolAseo = this.tipoAseoList[2]?.ctrol_aseo || this.tipoAseoList[0].ctrol_aseo;
          }
        } else {
          this.error = data.message || 'Error al cargar tipos de aseo';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async buscarPagos() {
      this.error = '';
      this.pagos = [];
      this.loading = true;
      try {
        // Buscar contrato
        const resContrato = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'buscarContrato',
            params: { contrato: this.contrato, ctrol_aseo: this.ctrolAseo }
          })
        });
        const dataContrato = await resContrato.json();
        if (!dataContrato.success || !dataContrato.data.length) {
          this.error = 'No existe contrato, intenta con otro.';
          this.loading = false;
          return;
        }
        this.controlContrato = dataContrato.data[0].control_contrato;
        // Buscar pagos
        const resPagos = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'buscarPagos',
            params: { control_contrato: this.controlContrato }
          })
        });
        const dataPagos = await resPagos.json();
        if (dataPagos.success) {
          this.pagos = dataPagos.data;
        } else {
          this.error = dataPagos.message || 'No existen pagos para este contrato.';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async descargarEdoCuenta() {
      if (!this.controlContrato) return;
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'edoCuentaPDF',
            params: { control_contrato: this.controlContrato }
          })
        });
        const data = await res.json();
        if (data.success && data.data && data.data.pdf_url) {
          window.open(data.data.pdf_url, '_blank');
        } else {
          this.error = data.message || 'No se pudo generar el Edo. de Cuenta.';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    formatPeriodo(dateStr) {
      if (!dateStr) return '';
      // Espera formato ISO o yyyy-mm-dd
      const d = new Date(dateStr);
      if (isNaN(d)) return dateStr;
      return d.getFullYear() + '-' + (d.getMonth() + 1).toString().padStart(2, '0');
    },
    formatFecha(dateStr) {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      if (isNaN(d)) return dateStr;
      return d.toLocaleDateString('es-MX');
    }
  },
  mounted() {
    this.cargarTipoAseo();
  }
};
</script>

<style scoped>
.pagos-cons-cont-page {
  max-width: 1100px;
  margin: 0 auto;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
</style>
