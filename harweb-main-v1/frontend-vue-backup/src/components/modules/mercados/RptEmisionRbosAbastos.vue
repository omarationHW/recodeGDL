<template>
  <div class="rpt-emision-rbos-abastos">
    <h1>Emisión de Recibos de Abastos</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Emisión Recibos Abastos</li>
      </ol>
    </nav>
    <form @submit.prevent="fetchReport">
      <div class="form-row">
        <div class="form-group col-md-3">
          <label>Oficina</label>
          <select v-model="form.oficina" class="form-control" required>
            <option v-for="of in oficinas" :key="of.id" :value="of.id">{{ of.nombre }}</option>
          </select>
        </div>
        <div class="form-group col-md-3">
          <label>Mercado</label>
          <select v-model="form.mercado" class="form-control" required>
            <option v-for="m in mercados" :key="m.id" :value="m.id">{{ m.nombre }}</option>
          </select>
        </div>
        <div class="form-group col-md-2">
          <label>Año</label>
          <input type="number" v-model="form.axo" class="form-control" required min="1990" max="2100">
        </div>
        <div class="form-group col-md-2">
          <label>Periodo</label>
          <input type="number" v-model="form.periodo" class="form-control" required min="1" max="12">
        </div>
        <div class="form-group col-md-2 align-self-end">
          <button type="submit" class="btn btn-primary">Consultar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="my-3">
      <span class="spinner-border"></span> Cargando datos...
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="reportData && reportData.length">
      <h3>Resultados</h3>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Local</th>
            <th>Nombre</th>
            <th>Descripción</th>
            <th>Meses</th>
            <th>Renta</th>
            <th>Adeudo</th>
            <th>Recargos</th>
            <th>Subtotal</th>
            <th>Multa</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in reportData" :key="row.id_local">
            <td>{{ row.local }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.descripcion }}</td>
            <td>{{ row.meses }}</td>
            <td>{{ currency(row.renta) }}</td>
            <td>{{ currency(row.adeudo) }}</td>
            <td>{{ currency(row.recargos) }}</td>
            <td>{{ currency(row.subtotal) }}</td>
            <td>{{ currency(row.multa) }}</td>
            <td>
              <button class="btn btn-link btn-sm" @click="showRequerimientos(row.id_local)">Ver Requerimientos</button>
            </td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <strong>Total Adeudo: </strong>{{ currency(totalAdeudo) }}<br>
        <strong>Total Recargos: </strong>{{ currency(totalRecargos) }}<br>
        <strong>Total Subtotal: </strong>{{ currency(totalSubtotal) }}<br>
        <strong>Total Multa: </strong>{{ currency(totalMulta) }}
      </div>
    </div>
    <div v-if="showReqModal">
      <div class="modal-backdrop show"></div>
      <div class="modal show d-block" tabindex="-1">
        <div class="modal-dialog modal-lg">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title">Requerimientos del Local #{{ reqLocalId }}</h5>
              <button type="button" class="close" @click="showReqModal=false">&times;</button>
            </div>
            <div class="modal-body">
              <div v-if="loadingReq">Cargando...</div>
              <div v-else-if="requerimientos && requerimientos.length">
                <table class="table table-sm">
                  <thead>
                    <tr>
                      <th>Folio</th>
                      <th>Importe Multa</th>
                      <th>Importe Gastos</th>
                      <th>Fecha Emisión</th>
                      <th>Observaciones</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="req in requerimientos" :key="req.folio">
                      <td>{{ req.folio }}</td>
                      <td>{{ currency(req.importe_multa) }}</td>
                      <td>{{ currency(req.importe_gastos) }}</td>
                      <td>{{ req.fecha_emision }}</td>
                      <td>{{ req.observaciones }}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <div v-else>No hay requerimientos para este local.</div>
            </div>
            <div class="modal-footer">
              <button class="btn btn-secondary" @click="showReqModal=false">Cerrar</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptEmisionRbosAbastos',
  data() {
    return {
      form: {
        oficina: '',
        mercado: '',
        axo: new Date().getFullYear(),
        periodo: new Date().getMonth() + 1
      },
      oficinas: [],
      mercados: [],
      reportData: [],
      loading: false,
      error: '',
      showReqModal: false,
      reqLocalId: null,
      requerimientos: [],
      loadingReq: false
    }
  },
  computed: {
    totalAdeudo() {
      return this.reportData.reduce((sum, r) => sum + Number(r.adeudo || 0), 0);
    },
    totalRecargos() {
      return this.reportData.reduce((sum, r) => sum + Number(r.recargos || 0), 0);
    },
    totalSubtotal() {
      return this.reportData.reduce((sum, r) => sum + Number(r.subtotal || 0), 0);
    },
    totalMulta() {
      return this.reportData.reduce((sum, r) => sum + Number(r.multa || 0), 0);
    }
  },
  methods: {
    currency(val) {
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    },
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.reportData = [];
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'getReportData',
            params: this.form
          })
        });
        const data = await res.json();
        if (data.success) {
          this.reportData = data.data;
        } else {
          this.error = data.message || 'Error al consultar datos';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async showRequerimientos(id_local) {
      this.reqLocalId = id_local;
      this.showReqModal = true;
      this.loadingReq = true;
      this.requerimientos = [];
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'getRequerimientos',
            params: { id_local }
          })
        });
        const data = await res.json();
        if (data.success) {
          this.requerimientos = data.data;
        } else {
          this.requerimientos = [];
        }
      } catch (e) {
        this.requerimientos = [];
      } finally {
        this.loadingReq = false;
      }
    },
    async fetchOficinas() {
      // Simulación: en producción, cargar desde API
      this.oficinas = [
        { id: 1, nombre: 'Zona Centro' },
        { id: 2, nombre: 'Zona Olímpica' },
        { id: 3, nombre: 'Zona Oblatos' },
        { id: 4, nombre: 'Zona Minerva' },
        { id: 5, nombre: 'Cruz del Sur' }
      ];
      this.form.oficina = this.oficinas[0].id;
    },
    async fetchMercados() {
      // Simulación: en producción, cargar desde API según oficina
      this.mercados = [
        { id: 1, nombre: 'Mercado Abastos' },
        { id: 2, nombre: 'Mercado Libertad' },
        { id: 3, nombre: 'Mercado San Juan' }
      ];
      this.form.mercado = this.mercados[0].id;
    }
  },
  mounted() {
    this.fetchOficinas();
    this.fetchMercados();
  }
}
</script>

<style scoped>
.rpt-emision-rbos-abastos {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.modal-backdrop {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.5);
  z-index: 1040;
}
.modal {
  z-index: 1050;
}
</style>
