<template>
  <div class="module-view">
    <h1>Emisión de Recibos Laser</h1>
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-invoice" /></div>
      <div class="module-view-info">
        <h1>Emisión Laser</h1>
        <p>Mercados - Emisión Laser</p>
      </div>
    </div>

    <div class="module-view-content">
    <form @submit.prevent="fetchReport">
      <div class="form-row">
        <div class="form-group col-md-3">
          <label class="municipal-form-label">Oficina</label>
          <select v-model="form.oficina" class="municipal-form-control" required>
            <option v-for="of in oficinas" :key="of.id" :value="of.id">{{ of.nombre }}</option>
          </select>
        </div>
        <div class="form-group col-md-3">
          <label class="municipal-form-label">Año</label>
          <input type="number" v-model.number="form.axo" class="municipal-form-control" required />
        </div>
        <div class="form-group col-md-3">
          <label class="municipal-form-label">Periodo (Mes)</label>
          <input type="number" v-model.number="form.periodo" min="1" max="12" class="municipal-form-control" required />
        </div>
        <div class="form-group col-md-3">
          <label class="municipal-form-label">Mercado</label>
          <select v-model="form.mercado" class="municipal-form-control" required>
            <option v-for="m in mercados" :key="m.id" :value="m.id">{{ m.nombre }}</option>
          </select>
        </div>
      </div>
      <button type="submit" class="btn-municipal-primary">Generar Reporte</button>
    </form>

    <div v-if="loading" class="mt-3">
      <span>Cargando...</span>
    </div>

    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>

    <div v-if="report && report.length" class="mt-4">
      <h3>Locales con Adeudo</h3>
      <table class="-bordered municipal-table-sm">
        <thead>
          <tr>
            <th>Local</th>
            <th>Nombre</th>
            <th>Descripción</th>
            <th>Meses Adeudo</th>
            <th>Renta</th>
            <th>Recargos</th>
            <th>Subtotal</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="loc in report" :key="loc.id_local">
            <td>{{ loc.local }}</td>
            <td>{{ loc.nombre }}</td>
            <td>{{ loc.descripcion_local }}</td>
            <td>{{ loc.meses }}</td>
            <td>{{ currency(loc.rentaaxos) }}</td>
            <td>{{ currency(loc.recargos) }}</td>
            <td>{{ currency(loc.subtotal) }}</td>
            <td>
              <button class="btn btn-link btn-sm" @click="showDetalle(loc)">Detalle</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="detalleLocal" class="modal fade show d-block" tabindex="-1" role="dialog">
      <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Detalle del Local #{{ detalleLocal.id_local }}</h5>
            <button type="button" class="close" @click="detalleLocal=null"><span>&times;</span></button>
          </div>
          <div class="modal-body">
            <h6>Pagos</h6>
            <table class="municipal-table-sm">
              <thead>
                <tr>
                  <th>Fecha Pago</th>
                  <th>Importe</th>
                  <th>Folio</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="p in pagos" :key="p.id_pago_local">
                  <td>{{ p.fecha_pago }}</td>
                  <td>{{ currency(p.importe_pago) }}</td>
                  <td>{{ p.folio }}</td>
                </tr>
              </tbody>
            </table>
            <h6>Meses Adeudo</h6>
            <ul>
              <li v-for="m in mesesAdeudo" :key="m.id_adeudo_local">
                {{ m.axo }}-{{ m.periodo }}: {{ currency(m.importe) }}
              </li>
            </ul>
            <h6>Requerimientos</h6>
            <ul>
              <li v-for="r in requerimientos" :key="r.folio">
                Folio: {{ r.folio }}, Multa: {{ currency(r.importe_multa) }}, Gastos: {{ currency(r.importe_gastos) }}
              </li>
            </ul>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" @click="detalleLocal=null">Cerrar</button>
          </div>
        </div>
      </div>
    </div>

  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'RptEmisionLaserPage',
  data() {
    return {
      form: {
        oficina: '',
        axo: new Date().getFullYear(),
        periodo: new Date().getMonth() + 1,
        mercado: ''
      },
      oficinas: [],
      mercados: [],
      report: [],
      loading: false,
      error: '',
      detalleLocal: null,
      pagos: [],
      mesesAdeudo: [],
      requerimientos: []
    }
  },
  created() {
    this.fetchOficinas();
  },
  methods: {
    fetchOficinas() {
      // Simulación: en real, llamar API
      this.oficinas = [
        { id: 1, nombre: 'Zona Centro' },
        { id: 2, nombre: 'Zona Olímpica' },
        { id: 3, nombre: 'Zona Oblatos' },
        { id: 4, nombre: 'Zona Minerva' },
        { id: 5, nombre: 'Zona Cruz del Sur' }
      ];
      this.form.oficina = this.oficinas[0].id;
      this.fetchMercados();
    },
    fetchMercados() {
      // Simulación: en real, llamar API
      this.mercados = [
        { id: 1, nombre: 'Mercado 1' },
        { id: 2, nombre: 'Mercado 2' },
        { id: 3, nombre: 'Mercado 3' }
      ];
      this.form.mercado = this.mercados[0].id;
    },
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.report = [];
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          eRequest: {
            action: 'getReport',
            params: {
              oficina: this.form.oficina,
              axo: this.form.axo,
              periodo: this.form.periodo,
              mercado: this.form.mercado
            }
          }
        }
          )
        });
        const respData = await resp.json();
        if (respData.eResponse && respData.eResponse.report) {
          this.report = respData.eResponse.report;
        } else {
          this.error = respData.eResponse.error || 'No se encontraron datos.';
        }
      } catch (e) {
        this.error = e.message || 'Error al consultar el reporte';
      } finally {
        this.loading = false;
      }
    },
    async showDetalle(local) {
      this.detalleLocal = local;
      // Cargar pagos
      const pagosResp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
        eRequest: {
          action: 'getPagos',
          params: { id_local: local.id_local, axo: this.form.axo, periodo: this.form.periodo }
        }
      });
      this.pagos = pagosRespData.eResponse.pagos || [];
      // Cargar meses adeudo
      const mesesResp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
        eRequest: {
          action: 'getMesAdeudo',
          params: { id_local: local.id_local, axo: this.form.axo }
        }
      });
      this.mesesAdeudo = mesesRespData.eResponse.mes_adeudo || [];
      // Cargar requerimientos
      const reqResp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
        eRequest: {
          action: 'getRequerimientos',
          params: { id_local: local.id_local, modulo: 11 }
        }
      });
      this.requerimientos = reqRespData.eResponse.requerimientos || [];
    },
    currency(val) {
      if (val == null) return '';
      return '$' + Number(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
}
</script>

<style scoped>
.rpt-emision-laser-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: #f8f9fa;
  padding: 0.5rem 1rem;
  margin-bottom: 1rem;
}
.modal {
  background: rgba(0,0,0,0.3);
}
</style>
