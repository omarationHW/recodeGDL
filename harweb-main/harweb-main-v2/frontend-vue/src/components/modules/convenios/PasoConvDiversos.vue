<template>
  <div class="container-fluid">
    <h2>Actualización de Convenios Diversos</h2>
    <div class="mb-3">
      <input type="file" @change="onFileChange" accept=".txt,.csv" />
      <button class="btn btn-primary" @click="parseFile">Cargar Archivo</button>
    </div>
    <div v-if="rows.length">
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th v-for="col in columns" :key="col">{{ col }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in rows" :key="idx">
            <td v-for="col in columns" :key="col">{{ row[col] }}</td>
          </tr>
        </tbody>
      </table>
      <button class="btn btn-success" @click="processRows">Actualizar Convenios</button>
    </div>
    <div v-if="result.message" :class="{'alert': true, 'alert-success': result.success, 'alert-danger': !result.success}">
      {{ result.message }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'PasoConvDiversos',
  data() {
    return {
      file: null,
      rows: [],
      columns: [
        'tipo','subtipo','manzana','lote','letra','rec','zona','nombre','calle','exterior','interior','inciso','fecha_inicio','fecha_venc','pago_total','pago_inicio','pago_parcial','pago_final','total_pagos','metros','tipo_pago','observaciones','vigencia','usuario','actualizacion','fecha_actual'
      ],
      result: {}
    };
  },
  methods: {
    onFileChange(e) {
      this.file = e.target.files[0];
    },
    parseFile() {
      if (!this.file) return alert('Seleccione un archivo');
      const reader = new FileReader();
      reader.onload = (e) => {
        const lines = e.target.result.split(/\r?\n/).filter(l => l.trim() !== '');
        // Suponiendo formato delimitado por | (pipe)
        this.rows = lines.map(line => {
          const parts = line.split('|');
          let obj = {};
          this.columns.forEach((col, idx) => {
            obj[col] = parts[idx] || '';
          });
          return obj;
        });
      };
      reader.readAsText(this.file);
    },
    async processRows() {
      if (!this.rows.length) return alert('No hay filas para procesar');
      this.result = { message: 'Procesando...', success: true };
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'process_rows',
            payload: {
              rows: this.rows,
              user_id: this.$store?.state?.user?.id || 1
            }
          })
        });
        this.result = await res.json();
      } catch (e) {
        this.result = { message: e.message, success: false };
      }
    }
  }
};
</script>

<style scoped>
.container-fluid { max-width: 1200px; margin: 0 auto; }
table { font-size: 0.95em; }
.alert { margin-top: 1em; }
</style>
