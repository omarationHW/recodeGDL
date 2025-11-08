<template>
  <div class="consmulpagos-page">
    <h1>Consulta de Pagos de Multas</h1>
    <form @submit.prevent="buscarPagos">
      <div class="form-row">
        <label>Fecha:
          <input type="date" v-model="filtros.fecha" />
        </label>
        <label>Recaudadora:
          <input type="number" v-model="filtros.recaud" min="1" />
        </label>
        <label>Caja:
          <input type="text" v-model="filtros.caja" maxlength="1" />
        </label>
        <label>Folio:
          <input type="number" v-model="filtros.folio" min="1" />
        </label>
        <label>Nombre:
          <input type="text" v-model="filtros.nombre" />
        </label>
        <label>No. Acta:
          <input type="number" v-model="filtros.num_acta" min="1" />
        </label>
        <button type="submit">Buscar</button>
        <button type="button" @click="limpiar">Limpiar</button>
      </div>
    </form>
    <div class="table-responsive">
      <table class="table table-bordered table-sm mt-3">
        <thead>
          <tr>
            <th>Fecha Pago</th>
            <th>Recaud</th>
            <th>Caja</th>
            <th>Folio</th>
            <th>Importe</th>
            <th>Contribuyente</th>
            <th>Domicilio</th>
            <th>No. Acta</th>
            <th>Año Acta</th>
            <th>Dependencia</th>
            <th>Detalle</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="pago in pagos" :key="pago.cvepago">
            <td>{{ pago.fecha }}</td>
            <td>{{ pago.recaud }}</td>
            <td>{{ pago.caja }}</td>
            <td>{{ pago.folio }}</td>
            <td>{{ pago.importe | currency }}</td>
            <td>{{ pago.contribuyente }}</td>
            <td>{{ pago.domicilio }}</td>
            <td>{{ pago.num_acta }}</td>
            <td>{{ pago.axo_acta }}</td>
            <td>{{ pago.id_dependencia }}</td>
            <td><button @click="verDetalle(pago.cvepago)">Ver</button></td>
          </tr>
        </tbody>
      </table>
      <div v-if="pagos.length === 0" class="alert alert-info mt-3">No hay pagos para mostrar.</div>
    </div>
    <div v-if="detallePago" class="detalle-modal">
      <div class="modal-content">
        <h3>Detalle de Pago</h3>
        <pre>{{ detallePago }}</pre>
        <button @click="detallePago = null">Cerrar</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsMulPagosPage',
  data() {
    return {
      filtros: {
        fecha: '',
        recaud: '',
        caja: '',
        folio: '',
        nombre: '',
        num_acta: ''
      },
      pagos: [],
      detallePago: null
    }
  },
  methods: {
    async buscarPagos() {
      const eRequest = {
        action: 'filter',
        params: { ...this.filtros }
      };
      const resp = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest })
      });
      const data = await resp.json();
      this.pagos = data.eResponse.result || [];
      this.detallePago = null;
    },
    async verDetalle(cvepago) {
      const eRequest = {
        action: 'detail',
        params: { cvepago }
      };
      const resp = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest })
      });
      const data = await resp.json();
      this.detallePago = data.eResponse.result;
    },
    limpiar() {
      this.filtros = { fecha: '', recaud: '', caja: '', folio: '', nombre: '', num_acta: '' };
      this.pagos = [];
      this.detallePago = null;
    }
  },
  filters: {
    currency(val) {
      if (!val) return '$0.00';
      return '$' + parseFloat(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  },
  mounted() {
    // Carga inicial
    this.buscarPagos();
  }
}
</script>

<style scoped>
.consmulpagos-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.form-row {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  align-items: flex-end;
}
.table-responsive {
  overflow-x: auto;
}
.detalle-modal {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}
.modal-content {
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  min-width: 400px;
}
</style>
