<template>
  <div class="imp-licencia-reglamentada">
    <h2 class="text-center">IMPRESION DE LICENCIAS REGLAMENTADAS</h2>
    <div class="form-section">
      <label for="licencia">No. de licencia:</label>
      <input
        id="licencia"
        v-model="licenciaInput"
        @keyup.enter="buscarLicencia"
        type="number"
        class="form-control"
        :disabled="loading"
        placeholder="Ingrese el número de licencia"
      />
      <button class="btn btn-primary mt-2" @click="buscarLicencia" :disabled="loading || !licenciaInput">
        Buscar
      </button>
    </div>
    <div v-if="error" class="alert alert-danger mt-2">{{ error }}</div>
    <div v-if="licenciaData" class="mt-4">
      <div class="row mb-2">
        <div class="col-md-3"><strong>Recaudadora:</strong> {{ licenciaData.licencia.recaud }}</div>
        <div class="col-md-3"><strong>Giro:</strong> {{ licenciaData.giro.descripcion }}</div>
        <div class="col-md-3"><strong>Clasificación:</strong> <span :class="{'font-weight-bold': true}">{{ licenciaData.giro.clasificacion }}</span></div>
      </div>
      <div class="row mb-2">
        <div class="col-md-6"><strong>Actividad:</strong> {{ licenciaData.licencia.actividad }}</div>
      </div>
      <div class="row mb-2">
        <div class="col-md-6"><strong>Propietario:</strong> {{ licenciaData.licencia.propietario }}</div>
      </div>
      <div class="row mb-2">
        <div class="col-md-6"><strong>Ubicación:</strong> {{ licenciaData.licencia.ubicacion }}</div>
        <div class="col-md-2"><strong>No. ext.:</strong> {{ licenciaData.licencia.numext_ubic }}</div>
        <div class="col-md-2"><strong>Letra ext.:</strong> {{ licenciaData.licencia.letraext_ubic }}</div>
        <div class="col-md-2"><strong>No. int.:</strong> {{ licenciaData.licencia.numint_ubic }}</div>
        <div class="col-md-2"><strong>Letra int.:</strong> {{ licenciaData.licencia.letraint_ubic }}</div>
      </div>
      <div class="row mb-2">
        <div class="col-md-3"><strong>Cve. Catastral:</strong> {{ licenciaData.convcta ? licenciaData.convcta.cvecatnva : '' }}</div>
        <div class="col-md-2"><strong>Subpredio:</strong> {{ licenciaData.convcta ? licenciaData.convcta.subpredio : '' }}</div>
        <div class="col-md-2"><strong>Zona:</strong> {{ licenciaData.licencia.zona }}</div>
        <div class="col-md-2"><strong>Subzona:</strong> {{ licenciaData.licencia.subzona }}</div>
      </div>
      <div class="row mb-2">
        <div class="col-md-3"><strong>Superficie autorizada:</strong> {{ licenciaData.licencia.sup_autorizada }}</div>
        <div class="col-md-3"><strong>Cajones estacionamiento:</strong> {{ licenciaData.licencia.num_cajones }}</div>
        <div class="col-md-3"><strong>Aforo personas:</strong> {{ licenciaData.licencia.aforo }}</div>
      </div>
      <div class="row mb-2">
        <div class="col-md-3"><strong>Nombre:</strong> {{ licenciaData.licencia.propietario }}</div>
        <div class="col-md-3"><strong>RFC:</strong> {{ licenciaData.licencia.rfc }}</div>
        <div class="col-md-3"><strong>CURP:</strong> {{ licenciaData.licencia.curp }}</div>
      </div>
      <div class="row mb-2">
        <div class="col-md-6"><strong>Especificaciones públicas:</strong> {{ licenciaData.licencia.espubic }}</div>
        <div class="col-md-6"><strong>Fecha Consejo:</strong> {{ licenciaData.licencia.fecha_consejo }}</div>
      </div>
      <div class="row mb-2">
        <div class="col-md-6">
          <span class="badge badge-info" v-if="licenciaData.licencia.asiento == 1">LICENCIA NUEVA</span>
          <span class="badge badge-warning" v-else>MODIFICACIÓN DE LICENCIA</span>
        </div>
        <div class="col-md-6">
          <span class="badge badge-danger" v-if="licenciaData.giro.reglamentada === 'S'">GIRO DE CONTROL ESPECIAL</span>
        </div>
      </div>
      <div class="row mt-3">
        <div class="col-md-12">
          <button class="btn btn-success" @click="imprimirLicencia" :disabled="imprimiendo || !puedeImprimir">
            <span v-if="imprimiendo"><i class="fa fa-spinner fa-spin"></i> Imprimiendo...</span>
            <span v-else>Imprimir</span>
          </button>
        </div>
      </div>
      <div v-if="adeudoData && adeudoData.length" class="mt-4">
        <h4>Detalle de Adeudo</h4>
        <table class="table table-bordered table-sm">
          <thead>
            <tr>
              <th>Número</th>
              <th>Texto</th>
              <th>Cta. Aplicación</th>
              <th>Importe</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in adeudoData" :key="row.id_registro">
              <td>{{ row.numero }}</td>
              <td>{{ row.texto }}</td>
              <td>{{ row.ctaapl }}</td>
              <td>{{ row.importe | currency }}</td>
            </tr>
            <tr>
              <td colspan="3" class="text-right font-weight-bold">TOTAL</td>
              <td class="font-weight-bold">{{ totalAdeudo | currency }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-if="imprimirMensaje" class="alert alert-success mt-2">{{ imprimirMensaje }}</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ImpLicenciaReglamentada',
  data() {
    return {
      licenciaInput: '',
      licenciaData: null,
      adeudoData: [],
      loading: false,
      error: '',
      imprimiendo: false,
      imprimirMensaje: '',
      puedeImprimir: false
    };
  },
  computed: {
    totalAdeudo() {
      if (!this.adeudoData || !this.adeudoData.length) return 0;
      return this.adeudoData.reduce((sum, row) => sum + Number(row.importe || 0), 0);
    }
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') val = parseFloat(val);
      return isNaN(val) ? '' : '$' + val.toLocaleString('es-MX', {minimumFractionDigits: 2});
    }
  },
  methods: {
    async buscarLicencia() {
      this.error = '';
      this.licenciaData = null;
      this.adeudoData = [];
      this.puedeImprimir = false;
      if (!this.licenciaInput) {
        this.error = 'Ingrese el número de licencia';
        return;
      }
      this.loading = true;
      try {
        const resp = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({
            action: 'getLicenciaReglamentada',
            params: {licencia: this.licenciaInput}
          })
        });
        const data = await resp.json();
        if (!data.eResponse.success || !data.eResponse.data.result || !data.eResponse.data.result.licencia) {
          this.error = data.message || 'Licencia no encontrada';
          this.loading = false;
          return;
        }
        // Validaciones de bloqueo y clasificación
        if (data.eResponse.data.result.licencia.bloqueado === 1) {
          this.error = 'La licencia está bloqueada.';
          this.loading = false;
          return;
        }
        if (data.eResponse.data.result.giro && data.eResponse.data.result.giro.clasificacion !== 'D') {
          this.error = 'El giro no es de clasificación D.';
          this.loading = false;
          return;
        }
        this.licenciaData = data.eResponse.data.result;
        this.puedeImprimir = true;
      } catch (e) {
        this.error = 'Error de comunicación con el servidor';
      } finally {
        this.loading = false;
      }
    },
    async imprimirLicencia() {
      if (!this.licenciaData || !this.licenciaData.licencia) return;
      this.imprimiendo = true;
      this.imprimirMensaje = '';
      try {
        // 1. Ejecutar cálculo de adeudo
        const calcResp = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({
            action: 'calcAdeudoLicencia',
            params: {id_licencia: this.licenciaData.licencia.id_licencia}
          })
        });
        const calcData = await calcResp.json();
        if (!calcData.success) {
          this.error = calcData.message || 'Error al calcular adeudo';
          this.imprimiendo = false;
          return;
        }
        // 2. Obtener detalle de adeudo
        const adeudoResp = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({
            action: 'getTmpAdeudoLic',
            params: {id_licencia: this.licenciaData.licencia.id_licencia}
          })
        });
        const adeudoData = await adeudoResp.json();
        if (!adeudoData.success) {
          this.error = adeudoData.message || 'Error al obtener detalle de adeudo';
          this.imprimiendo = false;
          return;
        }
        this.adeudoData = adeudoData.data;
        // Simular impresión (en real, aquí se llamaría a generación de PDF o similar)
        this.imprimirMensaje = 'Licencia lista para impresión (simulado).';
      } catch (e) {
        this.error = 'Error al imprimir licencia';
      } finally {
        this.imprimiendo = false;
      }
    }
  }
};
</script>

<style scoped>
.imp-licencia-reglamentada {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
.form-section {
  margin-bottom: 2rem;
}
.badge-info {
  background: #17a2b8;
  color: #fff;
}
.badge-warning {
  background: #ffc107;
  color: #212529;
}
.badge-danger {
  background: #dc3545;
  color: #fff;
}
</style>
