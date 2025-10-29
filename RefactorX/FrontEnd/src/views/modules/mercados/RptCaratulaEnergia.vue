<template>
  <div class="container mt-4">
    <h2>Carátula de Energía Eléctrica</h2>
    <div class="mb-3">
      <label class="municipal-form-label" for="id_local">ID Local</label>
      <input v-model="id_local" type="number" class="municipal-form-control" id="id_local" placeholder="Ingrese el ID del local" />
      <button class="btn btn-municipal-primary mt-2" @click="fetchCaratula">Consultar</button>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="caratula">
      <h4>Datos del Local</h4>
      <table class="municipal-table-bordered">
        <tr><th>Oficina</th><td>{{ caratula.oficina }}</td></tr>
        <tr><th>Num. Mercado</th><td>{{ caratula.num_mercado }}</td></tr>
        <tr><th>Sección</th><td>{{ caratula.seccion }}</td></tr>
        <tr><th>Local</th><td>{{ caratula.local }}</td></tr>
        <tr><th>Letra</th><td>{{ caratula.letra_local }}</td></tr>
        <tr><th>Bloque</th><td>{{ caratula.bloque }}</td></tr>
        <tr><th>Nombre</th><td>{{ caratula.nombre }}</td></tr>
        <tr><th>Consumo</th><td>{{ caratula.cve_consumo }} - {{ caratula.consumodescr }}</td></tr>
        <tr><th>Adicionales</th><td>{{ caratula.local_adicional }}</td></tr>
        <tr><th>Cantidad</th><td>{{ caratula.cantidad }}</td></tr>
        <tr><th>Vigencia</th><td>{{ caratula.vigdescripcion }}</td></tr>
        <tr><th>Fecha Alta</th><td>{{ caratula.fecha_alta }}</td></tr>
        <tr><th>Fecha Baja</th><td>{{ caratula.fecha_baja }}</td></tr>
        <tr><th>Usuario</th><td>{{ caratula.usuario }}</td></tr>
        <tr><th>Actualización</th><td>{{ caratula.fecha_modificacion }}</td></tr>
      </table>
      <h4>Resumen de Adeudos</h4>
      <table class="municipal-table-striped">
        <thead>
          <tr>
            <th>Periodo</th>
            <th>Adeudo</th>
            <th>Recargos</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="adeudo in adeudos" :key="adeudo.id_adeudo_energia">
            <td>{{ adeudo.axo }}-{{ adeudo.periodo }}</td>
            <td>{{ adeudo.importe }}</td>
            <td>{{ adeudo.recargos }}</td>
          </tr>
        </tbody>
      </table>
      <h4>Requerimientos</h4>
      <table class="municipal-table-striped">
        <thead>
          <tr>
            <th>Folio</th>
            <th>Importe Multa</th>
            <th>Importe Gastos</th>
            <th>Fecha Emisión</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="req in requerimientos" :key="req.id_control">
            <td>{{ req.folio }}</td>
            <td>{{ req.importe_multa }}</td>
            <td>{{ req.importe_gastos }}</td>
            <td>{{ req.fecha_emision }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <button class="btn btn-municipal-secondary" @click="printCaratula">Imprimir Carátula</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptCaratulaEnergia',
  data() {
    return {
      id_local: '',
      caratula: null,
      adeudos: [],
      requerimientos: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    async fetchCaratula() {
      this.loading = true;
      this.error = '';
      this.caratula = null;
      this.adeudos = [];
      this.requerimientos = [];
      try {
        // 1. Obtener carátula
        let res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'getEnergiaCaratula', params: { id_local: this.id_local } })
        });
        let data = await res.json();
        if (!data.success) throw new Error(data.message);
        this.caratula = data.data;
        // 2. Obtener adeudos
        res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'getAdeudosEnergia', params: { id_local: this.id_local } })
        });
        data = await res.json();
        if (!data.success) throw new Error(data.message);
        this.adeudos = data.data;
        // 3. Obtener requerimientos
        res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'getRequerimientosEnergia', params: { id_local: this.id_local } })
        });
        data = await res.json();
        if (!data.success) throw new Error(data.message);
        this.requerimientos = data.data;
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    printCaratula() {
      window.print();
    }
  }
};
</script>

<style scoped>
.container {
  max-width: 900px;
}
</style>
